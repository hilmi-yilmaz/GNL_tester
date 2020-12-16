/* ************************************************************************** */
/*                                                                            */
/*                                                        ::::::::            */
/*   main.c                                             :+:    :+:            */
/*                                                     +:+                    */
/*   By: hyilmaz <marvin@codam.nl>                    +#+                     */
/*                                                   +#+                      */
/*   Created: 2020/11/24 10:49:53 by hyilmaz       #+#    #+#                 */
/*   Updated: 2020/12/16 20:26:10 by hyilmaz       ########   odam.nl         */
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
	
	fd = 42;
	result = 1;
	line = NULL;
	while (result != 0)
	{
		result = get_next_line(fd, &line);
		if (result == 1)
			printf("%s\n",line);
		if (result == -1 || result == 0)
			break ;
		free(line);
		line = NULL;
	}
	close(fd);
	free(line);
	return (0);
}
