extends Node

class_name Logs

enum LOG_LEVEL {
	DEBUG,
	ERROR
}

const LogLevel : LOG_LEVEL = LOG_LEVEL.DEBUG

static func Debug(s : String):
	if LogLevel <= LOG_LEVEL.DEBUG:
		print("D: %s" % s)

static func Error(s : String):
	if LogLevel <= LOG_LEVEL.ERROR:
		print("E: %s" % s)
