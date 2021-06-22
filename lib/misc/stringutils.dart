import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Utility methods related to strings.
abstract class StringUtils {
  /// Generate a string with a list of hosts.
  ///
  /// No hosts: "TBD"
  ///
  /// 1 host: "<host1>"
  ///
  /// 2 hosts: "<host1> and <host2>"
  ///
  /// 3+ hosts: "<host1>, <host2>, ..."
  static String generatePrettyHostsList(List<String> hosts) {
    if (hosts.length == 0) {
      return "TBD";
    } else if (hosts.length == 2) {
      return "${hosts[0]} and ${hosts[1]}";
    } else {
      return hosts.join(", ");
    }
  }

  /// Generate a string with a "pretty" date.
  ///
  /// Sometime today: "Today at xx:xx"
  ///
  /// This week: "Monday"
  ///
  /// Other time: <time>
  static String generatePrettyDate(DateTime date) {
    DateTime now = DateTime.now().toUtc();
    if (date.isAfter(now)) {
      if (date.isBefore(now.add(Duration(days: 7)))) {
        if (date.day == now.day) {
          return DateFormat("'Today at' HH:mm").format(date);
        }
        return DateFormat("EEEE").format(date);
      }
    }

    return timeago.format(date);
  }
}
