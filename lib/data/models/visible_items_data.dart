class VisibleItemsData {
  int itemIndex;
  double startX;
  double endX;

  @override
  String toString() {
    return '{Item Index: $itemIndex, Start X: $startX, End X: $endX}';
  }

  VisibleItemsData(
      {required this.itemIndex, required this.startX, required this.endX});
}
