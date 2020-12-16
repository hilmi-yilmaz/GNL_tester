/* ************************************************************************** */
/*                                                                            */
/*                                                        ::::::::            */
/*   main.c                                             :+:    :+:            */
/*                                                     +:+                    */
/*   By: hyilmaz <marvin@codam.nl>                    +#+                     */
/*                                                   +#+                      */
/*   Created: 2020/11/24 10:49:53 by hyilmaz       #+#    #+#                 */
/*   Updated: 2020/12/16 20:02:08 by hyilmaz       ########   odam.nl         */
/*                                                                            */
/* ************************************************************************** */

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
	
	if (argc != 2)
		return (0);
	fd = open(*(argv + 1), O_RDONLY);
	result = 1;
	line = NULL;
	while (result != 0)
	{
		result = get_next_line(fd, &line);
		if (result == 1)
			printf("%s\n",line);
		//printf("result = %d\n\n", result);
		if (result == -1 || result == 0)
			break ;
		free(line);
		line = NULL;
	}
	close(fd);
	free(line);
	return (0);
}
