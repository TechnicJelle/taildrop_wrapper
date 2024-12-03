import "dart:io";

typedef Device = ({String ip, String name, String account, String os, String extra});

void showError(final String message, {final String? log}) {
  if (log != null) {
    stderr.write("$log\n");
  } else {
    stderr.write("$message\n");
  }
  final ProcessResult yadResult = Process.runSync("yad", [
    "--title=Taildrop",
    "--window-icon=taildrop_wrapper",
    "--center",
    "--image=dialog-error",
    "--text=$message",
    "--button=Close",
  ]);
  if (yadResult.exitCode != 0) {
    exit(yadResult.exitCode);
  }
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    showError(
      "No file provided.\n"
      "Usage:<span font='Monospace'> taildrop_wrapper &lt;file(s)&gt;</span>",
      log: "No file provided.\nUsage: taildrop_wrapper <file(s)>",
    );
    exit(1);
  }

  // Get devices from Tailscale
  final ProcessResult result;
  try {
    result = Process.runSync("tailscale", ["status", "--self=false"]);
  } catch (e) {
    if (e.toString().toLowerCase().contains("no such file or directory")) {
      showError("Tailscale is not installed or not on the PATH");
    } else {
      showError("An error occurred:\n$e");
    }
    exit(1);
  }
  final String output = result.stdout;

  // Check if Tailscale is up
  if (output.toLowerCase().contains("stopped")) {
    showError("Tailscale is not running");
    exit(1);
  }

  // Split output into lines
  final List<String> lines = output.split("\n").where((line) => line.isNotEmpty).toList();

  // Extract device info
  final extractInfoRegex = RegExp(
    r"(?<IP>.+?)\s+(?<Name>.+?)\s+(?<Account>.+?)\s+(?<OS>.+?)\s+(?<Extra>.*)",
  );

  final List<Device> devices = [];
  for (final String line in lines) {
    final RegExpMatch? match = extractInfoRegex.firstMatch(line);
    if (match != null) {
      if (match.namedGroup("Extra")!.toLowerCase().contains("offline")) continue;
      final Device device = (
        ip: match.namedGroup("IP")!,
        name: match.namedGroup("Name")!,
        account: match.namedGroup("Account")!,
        os: match.namedGroup("OS")!,
        extra: match.namedGroup("Extra")!,
      );
      devices.add(device);
    }
  }

  // Show devices in a dialog
  final String prettyFilesList = arguments.length == 1
      ? arguments.first
      : arguments.map((str) => " - $str").join("\n");
  final List<String> yadList = [];
  for (final Device device in devices) {
    yadList.addAll([device.name, device.account, device.os, device.ip, device.extra]);
  }
  final ProcessResult yadResult = Process.runSync("yad", [
    "--list",
    "--title=Taildrop to Device",
    "--window-icon=taildrop_wrapper",
    "--center",
    "--text=<span font='Monospace'>$prettyFilesList</span>\n"
        "Select a device to send the file(s) to:",
    "--column=Name",
    "--column=Account",
    "--column=OS",
    "--column=IP",
    "--column=Extra",
    ...yadList,
  ]);
  if (yadResult.exitCode != 0) {
    exit(yadResult.exitCode);
  }
  final String yadOutput = yadResult.stdout;

  // Get selected device
  final String deviceName = yadOutput.split("|").first.trim();

  //Send file to selected device
  print("Sending to: $deviceName\n$prettyFilesList");
  final ProcessResult sendResult = Process.runSync("tailscale", [
    "file",
    "cp",
    ...arguments,
    "$deviceName:",
  ]);
  if (sendResult.exitCode != 0) {
    showError("An error occurred:\n${sendResult.stderr}");
    exit(sendResult.exitCode);
  }

  // Notify user that the transfer is done
  Process.runSync("notify-send", [
    "-i",
    "taildrop_wrapper",
    "Taildrop",
    "File(s) transferred successfully",
  ]);
}
