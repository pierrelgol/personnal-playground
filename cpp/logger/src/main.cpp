/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/09/24 16:03:53 by pollivie          #+#    #+#             */
/*   Updated: 2024/09/24 16:03:54 by pollivie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Log.hpp"

int	main(int argc, char **argv) {

	if (argc != 1) {
		for (int i = 1; i < argc; ++i) {
			std::ostringstream msg(argv[i]);
			Logger::logDebug(std::ostringstream(msg));
			Logger::logInfo(msg);
			Logger::logSuccess(msg);
			Logger::logWarn(msg);
			Logger::logError(msg);
		}
	}
	return (0);
}
