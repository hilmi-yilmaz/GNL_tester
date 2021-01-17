#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "../src/get_next_line.h"

int		main(int argc, char **argv)
{
	int		fd;
	int 	result;
	char	*line;
	
	if (argc < 2)
        exit (1);
    
    /*
    ** Opening the files to read from and write the return values to.
    */

    fd = open(*(argv + 1), O_RDONLY);
    if (fd == -1)
        exit(1);
    
    /*
    ** Initializing some values
    */

    result = 1;
    line = NULL;

    /*
    ** Read the lines from fd and store in *line.
    ** The return values of get_next_line() are stored in fd_res.
    */

	while (result == 1)
	{
		result = get_next_line(fd, &line);
		printf("%s",line);
		printf("|%d|\n", result);
		free(line);
		line = NULL;
	}

    /*
    ** Close the file and free line.
    */

	close(fd);

	return (0);
}