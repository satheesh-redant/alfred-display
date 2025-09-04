class OdomState {
  final double posX;
  final double posY;
  final double oriX;
  final double oriY;
  final double oriZ;
  final double oriW;
  final double linVel;
  final double angVel;

  const OdomState({
    this.posX = 0.0,
    this.posY = 0.0,
    this.oriX = 0.0,
    this.oriY = 0.0,
    this.oriZ = 0.0,
    this.oriW = 0.0,
    this.linVel = 0.0,
    this.angVel = 0.0,
  });

  OdomState copyWith({
    double? posX,
    double? posY,
    double? oriX,
    double? oriY,
    double? oriZ,
    double? oriW,
    double? linVel,
    double? angVel,
  }) {
    return OdomState(
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      oriX: oriX ?? this.oriX,
      oriY: oriY ?? this.oriY,
      oriZ: oriZ ?? this.oriZ,
      oriW: oriW ?? this.oriW,
      linVel: linVel ?? this.linVel,
      angVel: angVel ?? this.angVel,
    );
  }
}
