# openHAB runtime configuration

## Logging configuration

To enable log rotation in _SLF4J_, add
```xml
<DefaultRolloverStrategy max="2" />
```
to these three blocks:
```xml
		<!-- Rolling file appender -->
		<RollingFile fileName="${sys:openhab.logdir}/openhab.log" filePattern="${sys:openhab.logdir}/openhab.log.%i" name="LOGFILE">
			.....
			<!-- added configuration goes here-->
		</RollingFile>

		<!-- Event log appender -->
		<RollingRandomAccessFile fileName="${sys:openhab.logdir}/events.log" filePattern="${sys:openhab.logdir}/events.log.%i" name="EVENT">
			.....
			<!-- added configuration goes here-->
		</RollingRandomAccessFile>

		<!-- Audit file appender -->
		<RollingRandomAccessFile fileName="${sys:openhab.logdir}/audit.log" filePattern="${sys:openhab.logdir}/audit.log.%i" name="AUDIT">
			.....
			<!-- added configuration goes here-->
		</RollingRandomAccessFile>
```

Have a look at [_log4j2.xml_](log4j2.xml) (line 16, 26, 36) to see how it should be.