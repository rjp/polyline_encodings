#include <stdlib.h>

int main(void)
{
	char string1[90], string2[90];

	char *string = "40.740190000000005,-73.98707";
	float d1, d2;
    double x;
    char *y;
	int result = sscanf(string, "%g, %g", &d1, &d2);
    x = strtod(string, &y);
	printf("%12g %12g %12lf %s\n", d1, d2, x, y);

	return 0;
}
