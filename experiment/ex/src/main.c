/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: pollivie <plgol.perso@gmail.com>           +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/11/01 12:29:22 by pollivie          #+#    #+#             */
/*   Updated: 2024/11/01 12:29:22 by pollivie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "foo.h"
#include <stdlib.h>
#include <string.h>

struct foo *create_foo(char *string) {
        struct foo *f = malloc(sizeof(struct foo));

        f->bar = malloc(strlen(string));
        strcpy(f->bar, string);
        return (f);
}

void destroy_foo(struct foo *ptr) {
        free(ptr->bar);
        free(ptr);
}

struct foo *bar() {
        struct foo *f = create_foo("hi");
        destroy_foo(f);
        return (f);
}

int main(void) {
        struct foo *t = bar();

        destroy_foo(t);

        return (0);
}
