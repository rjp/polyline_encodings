#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"


MODULE = Encode::Polylines::XS		PACKAGE = Encode::Polylines::XS		

void
hello()
    CODE:
    printf("hello world!\n");

char * 
encode(points)
    SV * points
INIT:
    char *output;
    int numpoints = av_len((AV *)SvRV(points));

    if ((!SvROK(points)
        || (SvTYPE(SvRV(points)) != SVt_PVAV)
        || numpoints < 0))
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

    sprintf(output, "x%d", numpoints);
    RETVAL = output;
OUTPUT:
    RETVAL


