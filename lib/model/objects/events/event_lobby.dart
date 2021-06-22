/// An event's lobby.
class EventLobby {
  /// The name of the lobby, or it's host (e.g. Lobby1, xxXXSuperHost123XXxx).
  final String? name;

  /// The address of the lobby.
  final String? address;

  EventLobby({required this.name, required this.address});

  factory EventLobby.fromJson(Map<String, dynamic> json) {
    return EventLobby(
      name: json['name'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'address': this.address,
    };
  }
}
