import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/store_create_model.dart';
import 'package:subhon_app/models/store_model.dart';
import 'package:subhon_app/models/store_update_model.dart';

import '../helpers/fake_backend.dart';

void main() {
  test('a store is read with city, region, format, counters, hours and the '
      'status reason; old records still read', () {
    final store = StoreModel.fromJson({
      ...ApiJson.store(),
      'city': 'Душанбе',
      'region': 'Dushanbe',
      'type': 'Supermarket',
      'counters': 4,
      'openingHours': '09:00–21:00',
      'statusNote': 'Ремонт',
    });
    expect(store.city, 'Душанбе');
    expect(store.region, 'Dushanbe');
    expect(store.type, 'Supermarket');
    expect(store.counters, 4);
    expect(store.openingHours, '09:00–21:00');
    expect(store.statusNote, 'Ремонт');
    expect(StoreModel.fromJson(ApiJson.store()).city, isNull);
  });

  test(
    'create sends only the given new fields; update clears emptied ones',
    () {
      expect(
        const StoreCreateModel(
          name: 'Бахор',
          city: 'Худжанд',
          counters: 2,
        ).toJson(),
        {'name': 'Бахор', 'status': 'ACTIVE', 'city': 'Худжанд', 'counters': 2},
      );
      expect(const StoreUpdateModel(region: 'Sughd').toJson(), {
        'region': 'Sughd',
      });
      expect(
        const StoreUpdateModel(
          region: 'Sughd',
        ).toJson(clear: StoreUpdateModel.clearable)['statusNote'],
        isNull,
      );
      expect(
        const StoreUpdateModel(
          region: 'Sughd',
        ).toJson(clear: StoreUpdateModel.clearable).containsKey('statusNote'),
        isTrue,
      );
    },
  );
}
