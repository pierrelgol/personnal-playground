/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   foo.h                                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: pollivie <plgol.perso@gmail.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/11/01 12:28:17 by pollivie          #+#    #+#             */
/*   Updated: 2024/11/01 12:28:17 by pollivie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FOO_H
#define FOO_H
#include <stdio.h>

struct foo {
                char *bar;
};

struct foo *create_foo(char *string);
void        destroy_foo(struct foo *ptr);

#endif
