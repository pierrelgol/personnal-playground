/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/01 12:29:33 by pollivie          #+#    #+#             */
/*   Updated: 2024/10/01 12:29:34 by pollivie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "BoundedArray.hpp"

#include <iostream>
#include <ostream>

#define N 10

int main(void) {
	BoundedArray<usize, N> data;

	std::cout << "push_back" << std::endl;
	for (usize i = 0; i < data.capacity(); i++) {
		data.push_back(i);
	}

	std::cout << "iterator" << std::endl;
	for (BoundedArray<usize, N>::const_iterator it = data.cbegin(); it != data.cend(); it++) {
		std::cout << *it << std::endl;
	}

	std::cout << "pop_front" << std::endl;
	int i = 0;
	while (i < N / 2) {
		Optional<usize> item = data.pop_front();
		if (item.safe_to_unwrap()) {
			std::cout << item.unwrap() << std::endl;
		}else {
			std::cout << "item is null" << std::endl;
		}
		i++;
	}

	std::cout << "iterator" << std::endl;
	for (BoundedArray<usize, N>::const_iterator it = data.cbegin(); it != data.cend(); it++) {
		std::cout << *it << std::endl;
	}


	return (0);
}
