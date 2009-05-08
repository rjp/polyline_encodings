#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#define IS_ARRAYREF(x) ((SvTYPE(SvRV(x)) == SVt_PVAV))
#define IS_DOUBLE(x) (SvNOK(x))
#define ARRAY_DOUBLE(x,y) (SvNV(*av_fetch(x, y, 0)))

MODULE = Encode::Polylines::XS		PACKAGE = Encode::Polylines::XS		

#include <gmp.h>
#include "encoder.c"

void
hello()
    CODE:
    printf("hello world!\n");

char * 
encode(points)
    SV * points
INIT:
    int n;
    char *output;
    /* do this later so we can take arrays or arrayrefs */
    AV *point_array = (AV *)SvRV(points) ;
    int numpoints = av_len(point_array);
    mpf_t old_lat, old_lng;

    if ((
          ! SvROK(points)
       || ! IS_ARRAYREF(points) /* have we an array ref? */
       || numpoints < 0
       || numpoints % 2 == 0 /* numpoints is (length-1) so %2 == 1 for even */
       ))
    {
        XSRETURN_UNDEF;
    }
CODE:
    /* 
     * allocate enough memory for our output string
     * up to 25 bits per number, 2 numbers per point
     * so we allocate 8 characters per point to be safe
     */
    output = (char *)malloc(8*numpoints);
    if (!output) {
        XSRETURN_UNDEF;
    }

    output[0] = '\0'; /* we use strcat so ensure a blank string */

    mpf_init_set_d(old_lat, 0.0);
    mpf_init_set_d(old_lng, 0.0);

    for (n=0; n <= numpoints; n+=2) {
        mpf_t plat, plng;
        mpf_init_set_d(plat, ARRAY_DOUBLE(point_array, n));
        mpf_init_set_d(plng, ARRAY_DOUBLE(point_array, n+1));
        encode_add_point(plat, plng, output, old_lat, old_lng);
        mpf_clear(plat);
        mpf_clear(plng);
    }

    mpf_clear(old_lat);
    mpf_clear(old_lng);

    RETVAL = output;
OUTPUT:
    RETVAL
