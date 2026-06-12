class Filter {
  final String? crop;
  final String? state;
  final String? market;

  const Filter({
    this.crop,
    this.state,
    this.market,
  });

  // Equatable would be better, but for this scope, a simple override is fine.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filter &&
          runtimeType == other.runtimeType &&
          crop == other.crop &&
          state == other.state &&
          market == other.market;

  @override
  int get hashCode => crop.hashCode ^ state.hashCode ^ market.hashCode;
}
