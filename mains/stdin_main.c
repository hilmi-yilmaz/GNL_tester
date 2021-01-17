/* ************************************************************************** */
/*                                                                            */
/*                                                        ::::::::            */
/*   main.c                                             :+:    :+:            */
/*                                                     +:+                    */
/*   By: hyilmaz <marvin@codam.nl>                    +#+                     */
/*                                                   +#+                      */
/*   Created: 2020/11/24 10:49:53 by hyilmaz       #+#    #+#                 */
/*   Updated: 2020/12/16 22:12:25 by hyilmaz       ########   odam.nl         */
/*                                                                            */
/* ************************************************************************** */

#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "../src/get_next_line.h"

int		main(void)
{
	int		fd;
	int 	result;
	char	*line;
	
	/*
    ** Initializing some values
    */

	fd = 0;
	result = 1;
	line = NULL;

    /*
    ** Read the lines from fd and store in *line.
    ** The return values of get_next_line() are stored in fd_res.
    */

	while (result != 0)
	{
		result = get_next_line(fd, &line);
		printf("%s",line);
		printf("|%d|\n", result);
		free(line);
		line = NULL;
	}

	/*
    ** Close the file.
    */

	close(fd);
	return (0);
}
