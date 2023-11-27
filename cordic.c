#define _POSIX_C_SOURCE 199309L

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define TESTS 10000
#define PRINT_CORDIC_SETUP 1
#define DEBUG 0
#define TAYLOR_TERMS 4
#define CORDIC_TERMS 15

#define M_PI 3.14159265358979323846
#define DEG_TO_RAD(deg) (deg * M_PI / 180.0)
#define RAD_TO_DEG(rad) (rad * 180.0 / M_PI)

#define FRACT_BITS 30
#define FIXED_ONE (1 << FRACT_BITS)
#define INT2FIXED(x) ((x) << FRACT_BITS)
#define FLOAT2FIXED(x) ((int)((x) * (1 << FRACT_BITS)))
#define FIXED2INT(x) ((x) >> FRACT_BITS)
#define FIXED2DOUBLE(x) (((double)(x)) / (1 << FRACT_BITS))

float taylor_cos(float theta, int n)
{
    float result = 0.0;
    for (int i = 0; i < n; i++)
    {
        int exponent = 2 * i;
        float term = pow(-1, i) * pow(theta, exponent) / tgamma(exponent + 1);
        result += term;
    }
    return result;
}

float taylor_sin(float theta, int n)
{
    float result = 0.0;
    for (int i = 0; i < n; i++)
    {
        int exponent = 2 * i + 1;
        float term = pow(-1, i) * pow(theta, exponent) / tgamma(exponent + 1);
        result += term;
    }
    return result;
}

int cordic(int theta, int gain, int *angles, int n, int *cos, int *sin)
{
    int x = gain;
    int y = 0.0;
    int x_new, y_new;
    for (int i = 0; i < n; i++)
    {
        if (theta > 0)
        {
            theta -= angles[i];
            x_new = x - (y >> i);
            y_new = y + (x >> i);
        }
        else
        {
            theta += angles[i];
            x_new = x + (y >> i);
            y_new = y - (x >> i);
        }
        x = x_new;
        y = y_new;
    }
    *cos = x;
    *sin = y;
}

int main(void)
{

#if (PRINT_CORDIC_SETUP || DEBUG)
    printf("Note: floats are converted to SFXP2_30\n");
    printf("Number of CORDIC Terms: %d\n", CORDIC_TERMS);
    printf("Angles Table (atan(2^(-i))):\n");
    printf("%-5s%-15s%-15s%-15s\n", "i", "angle (deg)", "angle (rad)", "angle (hex)");
#endif

    float gain = 1.0;
    int *angles = malloc(sizeof(int) * CORDIC_TERMS);
    for (int i = 0; i < CORDIC_TERMS; i++)
    {
        float phi = atanf(pow(2, -1 * i));
        gain *= cosf(phi);
        angles[i] = FLOAT2FIXED(phi);
#if (PRINT_CORDIC_SETUP || DEBUG)
        printf("%-5d%-15f%-15f32'h%08x\n", i, RAD_TO_DEG(phi), phi, angles[i]);
#endif
    }
    int fixed_gain = FLOAT2FIXED(gain);

#if (PRINT_CORDIC_SETUP || DEBUG)
    printf("CORDIC Gain: %f, 32'h%08x\n\n", gain, fixed_gain);
#endif

    srand(time(NULL));
    struct timespec start, end;
    float cos, sin, cos_taylor, sin_taylor;
    int cos_cordic, sin_cordic;
    long *taylor_time = malloc(sizeof(long) * TESTS);
    float *taylor_error = malloc(sizeof(float) * TESTS);
    long *cordic_time = malloc(sizeof(long) * TESTS);
    float *cordic_error = malloc(sizeof(float) * TESTS);
    for (int i = 0; i < TESTS; i++)
    {
        int deg = rand() % 180 - 90;
        float rad = DEG_TO_RAD(deg);
        int rad_fixed = FLOAT2FIXED(rad);

        clock_gettime(CLOCK_MONOTONIC, &start);
        cos_taylor = taylor_cos(rad, TAYLOR_TERMS);
        sin_taylor = taylor_sin(rad, TAYLOR_TERMS);
        clock_gettime(CLOCK_MONOTONIC, &end);
        taylor_time[i] = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec);

        clock_gettime(CLOCK_MONOTONIC, &start);
        cordic(rad_fixed, fixed_gain, angles, CORDIC_TERMS, &cos_cordic, &sin_cordic);
        clock_gettime(CLOCK_MONOTONIC, &end);
        cordic_time[i] = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec);

        cos = cosf(rad);
        sin = sinf(rad);
        taylor_error[i] = (fabs(cos_taylor - cos)) + fabs((sin_taylor - sin)) / 2;
        cordic_error[i] = (fabs(FIXED2DOUBLE(cos_cordic) - cos) + fabs(FIXED2DOUBLE(sin_cordic) - sin)) / 2;

#if (DEBUG)
        printf("===================== TEST %d =====================\n", i);
        printf("Angle: %d deg, %f rad, 32'h%08x\n", deg, rad, rad_fixed);
        printf("Taylor execution time: %ld ns\n", taylor_time[i]);
        printf("CORDIC execution time: %ld ns\n", cordic_time[i]);
        printf("math.h cos(%d): %f, sin(%d) %f\n", deg, cos, deg, sin);
        printf("Taylor cos(%d): %f, sin(%d): %f\n", deg, cos_taylor, deg, sin_taylor);
        printf("CORDIC cos(%d): %f (32'h%08x), sin(%d): %f (32'h%08x)\n\n", deg, FIXED2DOUBLE(cos_cordic), cos_cordic, deg, FIXED2DOUBLE(sin_cordic), sin_cordic);
#endif
    }

    long taylor_total_time = 0, cordic_total_time = 0;
    float taylor_total_error = 0, cordic_total_error = 0;
    for (int i = 0; i < TESTS; i++)
    {
        taylor_total_time += taylor_time[i];
        taylor_total_error += taylor_error[i];
        cordic_total_time += cordic_time[i];
        cordic_total_error += cordic_error[i];
    }

    printf("Tests: %d, Taylor Terms: %d, CORDIC Terms: %d\n", TESTS, TAYLOR_TERMS, CORDIC_TERMS);
    printf("Taylor average execution time: %ld ns\n", taylor_total_time / TESTS);
    printf("Taylor average error: %f\n", taylor_total_error / TESTS);
    printf("CORDIC average execution time: %ld ns\n", cordic_total_time / TESTS);
    printf("CORDIC average error: %f\n", cordic_total_error / TESTS);

    free(cordic_error);
    free(cordic_time);
    free(taylor_error);
    free(taylor_time);
    free(angles);
    return 0;
}
