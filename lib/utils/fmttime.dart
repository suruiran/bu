abstract class IDatetimeI18nImpl {
  String meridiem(int hour, String placeholder);
  String month(int month, String placeholder);
  String weekday(int weekday, String placeholder);
  String tz(Duration offset, String placeholder);
}

const _MMM = [
  "",
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

const _MMMM = [
  "",
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

const _dd = ["", "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
const _ddd = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const _dddd = [
  "",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

class _DefaultDatetimeI18nImpl extends IDatetimeI18nImpl {
  @override
  String meridiem(int hour, String placeholder) {
    final isAM = hour < 13;
    return placeholder == "a" ? (isAM ? "am" : "pm") : (isAM ? "AM" : "PM");
  }

  @override
  String month(int month, String placeholder) {
    return placeholder == "MMM" ? _MMM[month] : _MMMM[month];
  }

  @override
  String tz(Duration offset, String placeholder) {
    final sign = offset.isNegative ? "-" : "+";
    final hours = offset.inHours.abs();
    final minutes = offset.inMinutes.abs() % 60;

    switch (placeholder) {
      case "Z":
        {
          return "$sign${_pad(hours, 2)}:${_pad(minutes, 2)}";
        }
      case "ZZ":
        {
          return "$sign${_pad(hours, 2)}${_pad(minutes, 2)}";
        }
      default:
        {
          return placeholder;
        }
    }
  }

  @override
  String weekday(int weekday, String placeholder) {
    switch (placeholder) {
      case "dd":
        {
          return _dd[weekday];
        }
      case "ddd":
        {
          return _ddd[weekday];
        }
      case "dddd":
        {
          return _dddd[weekday];
        }
      default:
        {
          return placeholder;
        }
    }
  }
}

String fmttime({DateTime? time, String? layout, IDatetimeI18nImpl? i18n}) {
  time = time ?? DateTime.now();
  final parts = _compile(layout ?? "YYYY-MM-DD HH:mm:ss.SSS");
  final sb = StringBuffer();
  for (var ele in parts) {
    if (ele.isph) {
      sb.write(_replace(time, ele.value, i18n ?? _default_i18ns));
      continue;
    }
    sb.write(ele.value);
  }
  return sb.toString();
}

final _default_i18ns = _DefaultDatetimeI18nImpl();

String _replace(DateTime time, String placeholder, IDatetimeI18nImpl i18n) {
  switch (placeholder) {
    case "YYYY":
      {
        return _pad(time.year, 4);
      }
    case "YY":
      {
        return _pad(time.year % 100, 2);
      }
    case "M":
      {
        return time.month.toString();
      }
    case "MM":
      {
        return _pad(time.month, 2);
      }
    case "MMM":
    case "MMMM":
      {
        return i18n.month(time.month, placeholder);
      }
    case "D":
      {
        return time.day.toString();
      }
    case "DD":
      {
        return _pad(time.day, 2);
      }
    case "d":
      {
        return time.weekday.toString();
      }
    case "dd":
    case "ddd":
    case "dddd":
      {
        return i18n.weekday(time.weekday, placeholder);
      }
    case "H":
      {
        return time.hour.toString();
      }
    case "HH":
      {
        return _pad(time.hour, 2);
      }
    case "h":
      {
        final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
        return hour.toString();
      }
    case "hh":
      {
        final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
        return _pad(hour, 2);
      }
    case "a":
    case "A":
      {
        return i18n.meridiem(time.hour, placeholder);
      }
    case "m":
      {
        return time.minute.toString();
      }
    case "mm":
      {
        return _pad(time.minute, 2);
      }
    case "s":
      {
        return time.second.toString();
      }
    case "ss":
      {
        return _pad(time.second, 2);
      }
    case "SSS":
      {
        return _pad(time.millisecond, 3);
      }
    case "Z":
    case "ZZ":
      {
        return i18n.tz(time.timeZoneOffset, placeholder);
      }
  }
  return placeholder;
}

String _pad(int v, int len) {
  return v.toString().padLeft(len, "0");
}

typedef _Part = ({bool isph, String value});

List<_Part> _compile(String layout) {
  final List<_Part> parts = [];

  final regexp = RegExp(
    r'\[(?<literal>[^\]]+)\]'
    r'|YYYY'
    r'|YY'
    r'|M{1,4}'
    r'|D{1,2}'
    r'|d{1,4}'
    r'|H{1,2}'
    r'|h{1,2}'
    r'|a|A'
    r'|m{1,2}'
    r'|s{1,2}'
    r'|Z{1,2}'
    r'|SSS',
  );

  var cursor = 0;
  for (final ele in regexp.allMatches(layout)) {
    if (ele.start > cursor) {
      parts.add((isph: false, value: layout.substring(cursor, ele.start)));
    }
    final literal = ele.namedGroup('literal');
    if (literal == null) {
      parts.add((isph: true, value: layout.substring(ele.start, ele.end)));
    } else {
      final raw = ele.group(0)!;
      parts.add((isph: false, value: raw.substring(1, raw.length - 1)));
    }
    cursor = ele.end;
  }
  if (cursor < layout.length) {
    parts.add((isph: false, value: layout.substring(cursor)));
  }
  return parts;
}
