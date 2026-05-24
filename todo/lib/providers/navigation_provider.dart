import 'package:flutter_riverpod/legacy.dart';

// বটম নেভিগেশন বারের স্টেট ট্র্যাকিংয়ের জন্য আলাদা প্রোভাইডার
final navigationProvider = StateProvider<int>((ref) => 0);
