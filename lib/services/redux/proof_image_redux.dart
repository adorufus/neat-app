import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';

@immutable
class AppState {
  final Map<String, List> proofImages;

  const AppState(this.proofImages);
}

enum Actions {
  addProofImages
}

AppState reducer(AppState prev, action) {
  if(action == Actions.addProofImages) {
    return AppState(prev.proofImages);
  }

  return prev;
}

// class AddItemAction {
//   final Map<String, List>? items;
//
//   AddItemAction(this.items);
// }
//
// Map<String, List> proofImageReducer(Map<String, List> items, dynamic action) {
//   if(action == AddItemAction) {
//     print("test");
//     return addItem(items, action);
//   }
//
//   return items;
// }
//
// Map<String, List> addItem(Map<String, List> items, AddItemAction action) {
//   print("Redux: Item Added: "+ action.items.toString());
//   return Map.from(items)..addAll(action.items!);
// }

