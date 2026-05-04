import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';

abstract class BaseBot {
  const BaseBot();
  
  String get name;
  
  void takeTurn(dynamic runner);

  EventChoice chooseEventAction(dynamic runner, LifeEvent event);
}
