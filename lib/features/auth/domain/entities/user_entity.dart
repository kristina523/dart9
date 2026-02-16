import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final bool emailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    required this.emailVerified,
  });

  @override
  List<Object?> get props => [id, email, displayName, emailVerified];
}

