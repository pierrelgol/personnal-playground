/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Log.hpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: pollivie <pollivie.student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/09/24 16:03:39 by pollivie          #+#    #+#             */
/*   Updated: 2024/09/24 16:03:40 by pollivie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef LOG_HPP
#define LOG_HPP

#include <iostream>
#include <ctime>
#include <string>
#include <sys/time.h>
#include <cstdio>
#include <sstream>

enum LogLevel {
	DEBUG,
	INFO,
	SUCCESS,
	WARN,
	ERROR,
};

static const char *getLevelString(LogLevel level)
{
	switch (level) {
	case DEBUG:
		return "DEBUG  ";
	case INFO:
		return "INFO   ";
	case SUCCESS:
		return "SUCCESS";
	case WARN:
		return "WARN   ";
	case ERROR:
		return "ERROR  ";
	}
	return "";
}

static const char *getColor(LogLevel level)
{
	switch (level) {
	case DEBUG:
		return "\033[33m";
	case INFO:
		return "\033[37m";
	case SUCCESS:
		return "\033[32m";
	case WARN:
		return "\033[35m";
	case ERROR:
		return "\033[31m";
	}
	return "\033[0m";
}

static std::string getCurrentTime()
{
	char buffer[64];
	struct timeval tv;
	gettimeofday(&tv, NULL);
	struct tm *ptm = localtime(&tv.tv_sec);
	std::sprintf(buffer, "%02d:%02d:%02d:%03ld", ptm->tm_hour, ptm->tm_min,
		     ptm->tm_sec, tv.tv_usec / 1000);
	return std::string(buffer);
}

class Logger {
    public:
	static void log(LogLevel level, const std::ostringstream &message)
	{
		std::cout << getColor(level) << "[" << getLevelString(level)
			  << "]"
			  << "[" << getCurrentTime() << "] " << message.str()
			  << "\033[0m" << std::endl;
	}

	static void logDebug(const std::ostringstream &message)
	{
		log(DEBUG, message);
	}

	static void logInfo(const std::ostringstream &message)
	{
		log(INFO, message);
	}

	static void logSuccess(const std::ostringstream &message)
	{
		log(SUCCESS, message);
	}

	static void logWarn(const std::ostringstream &message)
	{
		log(WARN, message);
	}

	static void logError(const std::ostringstream &message)
	{
		log(ERROR, message);
	}

	static std::ostringstream &stream()
	{
		static std::ostringstream oss;
		oss.str("");
		oss.clear();
		return oss;
	}
};

#endif // LOG_HPP
