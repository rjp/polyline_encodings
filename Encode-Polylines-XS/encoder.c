#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

void
debug(mpf_t x_input, long scaled, char *p)
{
    char input[1024];
    mp_exp_t e;

    mpf_get_str(input, &e, 10, 1000, x_input);
    fprintf(stderr, "%-16s: %s, %10lu, %08x\n", p, input, scaled, scaled);
}

/* buffer needs to be at least 8 characters long */
void
encode_number(mpf_t input, char *buffer, mpf_t output)
{
    int i;
    int chunk_i = -1;
    mpf_t abs_input, scale_factor, d_scaled, p_scaled;
    unsigned long scaled;

    mpf_init(d_scaled);
    mpf_init(p_scaled);
    mpf_init(abs_input);
    mpf_init_set_ui(scale_factor, 1e5); /* too many inits, use a static? */

    mpf_abs(abs_input, input);
    mpf_mul(p_scaled, abs_input, scale_factor);
    mpf_floor(d_scaled, p_scaled);

    scaled = mpf_get_ui(d_scaled);
    mpf_set(output, d_scaled);

    mpf_clear(abs_input);
    mpf_clear(scale_factor);
    mpf_clear(d_scaled);
    mpf_clear(p_scaled);

    debug(input, scaled, "scaled");

    if (input < 0) {
        int bitpoint = 1;
        scaled = scaled ^ 0xFFFFFFFF;
        while (scaled & bitpoint) {
            scaled = scaled & ~bitpoint;
            bitpoint = bitpoint << 1;
        }
        scaled = scaled ^ bitpoint;
        debug(input, scaled, "1st inversion");
    }

    scaled = (scaled << 1) & 0xFFFFFFFF;
    debug(input, scaled, "shift left");
    
    if (input < 0) {
        scaled = scaled ^ 0xFFFFFFFF;
        debug(input, scaled, "2nd inversion");
    }

    while (scaled != 0) {
        int chunk = scaled & 0x1F;
        chunk_i++;
        buffer[chunk_i] = chunk | 0x20;
        debug(input, scaled, "scaled");
        /*
        fprintf(stderr, "chunk %d is %d, %x\n", chunk_i,chunk,buffer[chunk_i]);
        */
        scaled = scaled >> 5;
        if (scaled == 0) {
            buffer[chunk_i] = chunk;
        }
    }

    for(i=0; i<=chunk_i; i++) {
        buffer[i] = buffer[i] + 63;
/*        fprintf(stderr, "character %d is %c, %x\n", i,buffer[i],buffer[i]); */
    }
    buffer[chunk_i+1] = '\0';
}

void
encode_add_point(mpf_t lat, mpf_t lng, char *buffer, mpf_t old_lat, mpf_t old_lng)
{
    char b[10];

    mpf_t dlat, dlng;
   
    mpf_init(dlat);
    mpf_init(dlng);

    mpf_sub(dlat, lat, old_lat);
    mpf_sub(dlng, lng, old_lng);

	encode_number(dlat, b, old_lat); strcat(buffer, b);
	encode_number(dlng, b, old_lng); strcat(buffer, b);
}

void
encode_points(double *list, int count, char **output)
{
    int i;
    mpf_t old_lat, old_lng;
    char *out;

    out = (char *)malloc(6*count*sizeof(char)+5);
    *output = out;

    /* make sure we have an empty string because we're using strcat */
    out[0] = '\0';

    mpf_init_set_d(old_lat, 0.0);
    mpf_init_set_d(old_lng, 0.0);
    
    for(i=0; i<count; i+=2) { /* lat, long, lat, long, ... */
        mpf_t plat, plng;

        mpf_init_set_d(plat, list[i]);
        mpf_init_set_d(plng, list[i+1]);

        encode_add_point(plat, plng, out, old_lat, old_lng);

        mpf_clear(plat);
        mpf_clear(plng);
	}

    mpf_clear(old_lat);
    mpf_clear(old_lng);
}
