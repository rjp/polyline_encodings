#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

void
debug(double input, long scaled, char *p)
{
    return;
    fprintf(stderr, "%-16s: %10.5f, %10lu, %08x\n", p, input, scaled, scaled);
}

/* buffer needs to be at least 8 characters long */
void
encode_number(mpf_t input, char *buffer)
{
    int i;
    int chunk_i = -1;
    mpf_t abs_input, scale_factor, d_scaled;
    unsigned long scaled;

    mpf_abs(abs_input, input);

    mpf_init_set_ui(scale_factor, 1e5);

    mpf_mul(d_scaled, abs_input, scale_factor);

    scaled = mpf_get_ui(d_scaled);

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

    mpf_t dlat = lat - *old_lat;
    mpf_t dlng = lng - *old_lng;

	encode_number(dlat, b); strcat(buffer, b);
	encode_number(dlng, b); strcat(buffer, b);

    mpf_set(old_lat, lat);
    mpf_set(old_lng, lng);
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

        plat = mpf_init_set_d(list[i]);
        plng = mpf_init_set_d(list[i+1]);
        encode_add_point(plat, plng, out, &old_lat, &old_lng);
	}
}

#ifdef TEST
int
main (void)
{
    int i;
    char b[8];

    encode_number(-73.97918, b);
    printf("test: %s\n", b);

    /*
    encode_number(38.5, b);
    printf("test: %s\n", b);
    encode_number(2.552, b);
    printf("test: %s\n", b);
    encode_number(2.2, b);
    printf("test: %s\n", b);
    */
    encode_number(-179.9832104, b);
    printf("test: %s\n", b);

    for(i=0; i<1500000; i++) {
        encode_number(-179.9832104, b);
    }

    {
        double points[] = {-45,-45, -15,15, 15,-15, 15.00988,-16.47231};
        char *x = "~`tqG~`tqG_kbvD_wemJ_kbvD~jbvDw|@|p~G";
        char out[1024];
        int i;
        double old_lat=0.0, old_lng=0.0;
        out[0] = '\0';

        for(i=0; i<(sizeof(points)/sizeof(double)); i+=2) {
            double lat = points[i] - old_lat;
            double lng = points[i+1] - old_lng;

            encode_number(lat, b); strcat(out, b);
            encode_number(lng, b); strcat(out, b);

            old_lat = points[i];
            old_lng = points[i+1];
        }
        printf("got : %s\nwant: %s\n", out, x);
    }

    {
        char out[1024], line[1024], *billy;
        char *x = "miywFz`pbMiFz`Ch}Ad_@fv@bB~X{rBm[w_CitAeQii@`^|GbdC`mAxYzP{rBmoA}KbThmArMk_A";
        int i;
        double old_lat=0.0, old_lng=0.0;
        FILE *f;

        out[0] = '\0';

        f = fopen("testfile", "r");
        if (!f) {
            perror("FISH!");
            exit(1);
        }
        printf("Opened testfile correctly\n");

        while (fgets(line, 1024, f) != NULL) {
            double plat=99, plng;
            double lat, lng;
            char *cdr;

            plat = strtod(line, &cdr);
            plng = strtod((char*)(cdr+1), NULL);

            fprintf(stderr, "got: %lf, %lf |%s", plat, plng, line);

            lat = plat - old_lat;
            lng = plng - old_lng;

            encode_number(lat, b); strcat(out, b);
            encode_number(lng, b); strcat(out, b);

            old_lat = plat;
            old_lng = plng;
        }
        printf("got : %s\nwant: ", out);
        for(i=0; i<strlen(x); i++) {
            if (out[i] != x[i]) {
                printf("%c[31m%c%c[0m", 27, x[i], 27);
            } else {
                printf("%c", x[i]);
            }
        }
        puts("");
    }

    {
        char *got;
        double a[] = { 40.76711,-73.97918,40.768280000000004,-73.99996 };
        encode_points(a, 4, &got);
        fprintf(stderr, "g=[%s]\n", got);
    }

}
#endif

