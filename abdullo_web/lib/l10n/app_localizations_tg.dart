// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tajik (`tg`).
class AppLocalizationsTg extends AppLocalizations {
  AppLocalizationsTg([String locale = 'tg']) : super(locale);

  @override
  String get navDashboard => 'Панели идора';

  @override
  String get navStores => 'Мағозаҳо';

  @override
  String get navSales => 'Фурӯш';

  @override
  String get navEmployees => 'Кормандон';

  @override
  String get navSalaries => 'Музди меҳнат';

  @override
  String get navReports => 'Ҳисоботҳо';

  @override
  String get navAssistant => 'Ёрдамчии AI';

  @override
  String get navProfile => 'Профил';

  @override
  String get navSettings => 'Танзимот';

  @override
  String get navMore => 'Боз';

  @override
  String get cancel => 'Бекор';

  @override
  String get save => 'Нигоҳ доштан';

  @override
  String get close => 'Пӯшидан';

  @override
  String get delete => 'Нест кардан';

  @override
  String get edit => 'Таҳрир';

  @override
  String get tryAgain => 'Аз нав кӯшиш кунед';

  @override
  String get loadError => 'Маълумот бор нашуд. Пайвастро санҷед ва аз нав кӯшиш кунед.';

  @override
  String get nothingFound => 'Ҳеҷ чиз ёфт нашуд';

  @override
  String get noDataYet => 'Ҳоло маълумот нест';

  @override
  String get today => 'Имрӯз';

  @override
  String get active => 'Фаъол';

  @override
  String get inactive => 'Ғайрифаъол';

  @override
  String inactiveWithReason(String reason) {
    return 'Ғайрифаъол ($reason)';
  }

  @override
  String get store => 'Мағоза';

  @override
  String get city => 'Шаҳр';

  @override
  String get status => 'Ҳолат';

  @override
  String get phone => 'Телефон';

  @override
  String get staff => 'Кормандон';

  @override
  String get name => 'Ном';

  @override
  String get role => 'Вазифа';

  @override
  String get shift => 'Баст';

  @override
  String get type => 'Навъ';

  @override
  String get share => 'Ҳисса';

  @override
  String get export => 'Содирот';

  @override
  String get allStores => 'Ҳамаи мағозаҳо';

  @override
  String get amountTjs => 'Маблағ (TJS)';

  @override
  String get enterAmount => 'Маблағи аз 0 зиёдро ворид кунед';

  @override
  String get required => 'Ҳатмӣ';

  @override
  String rowsCopied(int count) {
    return '$count сатр ҳамчун CSV нусха шуд — ба Excel гузоред';
  }

  @override
  String get pagerPrev => '‹ Қаблӣ';

  @override
  String get pagerNext => 'Баъдӣ ›';

  @override
  String showingRange(int from, int to, int total) {
    return '$from–$to аз $total нишон дода шуд';
  }

  @override
  String get language => 'Забон';

  @override
  String allStoresActive(int count) {
    return 'Ҳамаи мағозаҳо ($count фаъол)';
  }

  @override
  String get chooseStore => 'Интихоби мағоза';

  @override
  String get searchHint => 'Ҷустуҷӯи амалиёт, мағоза, корманд…';

  @override
  String get demoBadge => 'Маълумоти намунавӣ · API пайваст нест';

  @override
  String get notifications => 'Огоҳиҳо';

  @override
  String salariesWaiting(int count) {
    return '$count музд интизори пардохт';
  }

  @override
  String get noNotifications => 'Огоҳӣ нест';

  @override
  String get businessOverview => 'Шарҳи тиҷорат';

  @override
  String get liveAudit => 'Аудити зинда';

  @override
  String get overviewSubtitle => 'Нишондиҳандаҳои умумии ҳамаи филиалҳо ва гардиши пул дар вақти воқеӣ';

  @override
  String get recordSale => 'Сабти фурӯш';

  @override
  String todayDate(String date) {
    return 'Имрӯз: $date';
  }

  @override
  String get kpiTotalStores => 'Ҳамаи мағозаҳо';

  @override
  String nActive(int count) {
    return '$count фаъол';
  }

  @override
  String quarterNew(int count, int quarter) {
    return '+$count дар семоҳаи $quarter';
  }

  @override
  String ofRegistered(int count) {
    return 'аз $count сабтшуда';
  }

  @override
  String get kpiTotalStaff => 'Ҳамаи кормандон';

  @override
  String nStaff(int count) {
    return '$count нафар';
  }

  @override
  String get onShiftToday => 'имрӯз дар баст';

  @override
  String get kpiTodaySales => 'Фурӯши имрӯза';

  @override
  String get vsYesterday => 'нисбат ба дирӯз';

  @override
  String get kpiWeeklySales => 'Фурӯши ҳафтаина';

  @override
  String target(String value) {
    return 'Ҳадаф $value';
  }

  @override
  String get kpiMonthlySales => 'Фурӯши моҳона';

  @override
  String get mom => 'нисбат ба моҳи гузашта';

  @override
  String get kpiUnpaidSalaries => 'Музди пардохтнашуда';

  @override
  String nPending(int count) {
    return '$count дар интизор';
  }

  @override
  String cycle(String month) {
    return 'Давраи $month';
  }

  @override
  String get revenueTitle => 'Таҳлили даромад ва гардиши пул';

  @override
  String get revenueSubtitle => 'Динамикаи даромади ҳаррӯза дар моҳи ҷорӣ';

  @override
  String get weekly => 'Ҳафта';

  @override
  String get monthly => 'Моҳ';

  @override
  String peakLabel(String day, String amount) {
    return 'Авҷ: $day ($amount)';
  }

  @override
  String get peakShort => 'Авҷ';

  @override
  String get averageDaily => 'Миёнаи рӯзона: ';

  @override
  String get totalVolume => 'Ҳаҷми умумӣ: ';

  @override
  String txns(String count) {
    return '$count амалиёт';
  }

  @override
  String autoReconciliation(String pct) {
    return '$pct% мутобиқсозии худкор';
  }

  @override
  String get grossMargin => 'Фоидаи умумӣ';

  @override
  String get onlineSplit => 'Ҳиссаи онлайн / QR';

  @override
  String cardShare(String pct) {
    return '$pct% корт';
  }

  @override
  String get cashVaults => 'Нақд дар сейфҳо';

  @override
  String get topStores => 'Беҳтарин мағозаҳо';

  @override
  String get ranked => 'Рейтинг';

  @override
  String get rankedSubtitle => 'Аз рӯи ҳаҷми фурӯши моҳона';

  @override
  String countersType(String type, int count) {
    return '$type • $count касса';
  }

  @override
  String shareValue(String pct) {
    return 'Ҳисса $pct%';
  }

  @override
  String viewAllStores(int count) {
    return 'Ҳамаи $count мағоза';
  }

  @override
  String get recentActivity => 'Фаъолияти охирин';

  @override
  String get liveFeed => 'Лентаи зинда';

  @override
  String get activitySubtitle => 'Санҷишҳои молиявӣ, бастани кассаҳо ва ҷойгиркунии кормандон';

  @override
  String get demoFeed => 'Лентаи намунавӣ';

  @override
  String get syncActive => 'Ҳамоҳангсозӣ фаъол';

  @override
  String get filter => 'Филтр';

  @override
  String get allActivity => 'Ҳамаи фаъолиятҳо';

  @override
  String get activitySales => 'Фурӯш';

  @override
  String get activityPayroll => 'Музди меҳнат';

  @override
  String get activityAudits => 'Санҷишҳо';

  @override
  String get activityStaff => 'Кормандон';

  @override
  String get noActivity => 'Фаъолият ёфт нашуд';

  @override
  String get activityStores => 'Мағозаҳо';

  @override
  String get activityProfile => 'Профил';

  @override
  String get actCreated => 'сохта шуд';

  @override
  String get actUpdated => 'тағйир ёфт';

  @override
  String get actDeleted => 'нест карда шуд';

  @override
  String get actStatusChanged => 'ҳолат иваз шуд';

  @override
  String get actPaid => 'пардохт шуд';

  @override
  String get actCancelled => 'бекор карда шуд';

  @override
  String get assistantBusy => 'Саволҳо хеле зиёданд. Як дақиқа сабр карда, боз пурсед.';

  @override
  String connectedTo(String endpoints) {
    return 'Пайваст ба $endpoints';
  }

  @override
  String get demoBackend => 'Маълумоти намунавӣ — сервер ҳоло пайваст нест';

  @override
  String get salesEyebrow => 'Амалиётҳои молиявӣ · тоҷикистон';

  @override
  String get salesTitle => 'Фурӯш ва сабтҳои ҳаррӯза';

  @override
  String get salesSubtitle =>
      'Гардиши ҳаррӯзаи мағозаҳоро бо сомонӣ (TJS) сабт кунед ва амалиётҳоро дар вақти воқеӣ пайгирӣ намоед.';

  @override
  String get totalToday => 'Ҳамагӣ имрӯз';

  @override
  String get totalThisMonth => 'Ҳамагӣ дар ин моҳ';

  @override
  String get successPrefix => 'Бомуваффақият: ';

  @override
  String saleSavedMessage(String amount, String store) {
    return 'Фурӯш ба маблағи $amount барои $store сабт шуд.';
  }

  @override
  String get sessionClerk => 'Корманди ҷорӣ';

  @override
  String get authorized => 'Тасдиқшуда';

  @override
  String get storeLabel => 'Мағоза:';

  @override
  String get searchReceipt => 'Ҷустуҷӯ аз рӯи № ё қайдҳо…';

  @override
  String get updatedJustNow => 'Ҳозир навсозӣ шуд';

  @override
  String updatedMinutesAgo(int count) {
    return '$count дақиқа пеш навсозӣ шуд';
  }

  @override
  String get activeFilterVolume => 'Ҳаҷм аз рӯи филтр';

  @override
  String get filteredTotal => 'Ҳамагӣ аз рӯи филтр: ';

  @override
  String acrossEntries(int count) {
    return '  дар $count сабт';
  }

  @override
  String vsPrevPeriod(String pct) {
    return '$pct нисбат ба давраи пешина';
  }

  @override
  String get colDateTime => 'Сана ва вақт';

  @override
  String get colStoreName => 'Мағоза';

  @override
  String get colSalesAmount => 'Маблағи фурӯш';

  @override
  String get colRegisteredBy => 'Сабт кард';

  @override
  String get colNotesMethod => 'Қайдҳо / усул';

  @override
  String get noEntries => 'Барои ин филтр сабт нест';

  @override
  String get hourlyVelocity => 'Фурӯш аз рӯи соат (имрӯз)';

  @override
  String get reconciliation => 'Мутобиқсозӣ';

  @override
  String storesSynced(int synced, int total) {
    return '$synced аз $total мағоза имрӯз мутобиқ шуд';
  }

  @override
  String get rangeToday => 'Имрӯз';

  @override
  String get rangeWeek => 'Ин ҳафта';

  @override
  String get rangeMonth => 'Ин моҳ';

  @override
  String get rangeCustom => 'Давраи дилхоҳ';

  @override
  String get newDailySale => 'Сабти нави фурӯши рӯзона';

  @override
  String get posTerminal => 'POS-терминал';

  @override
  String get selectStore => 'Мағозаро интихоб кунед';

  @override
  String activeBranches(int count) {
    return '$count филиали фаъол';
  }

  @override
  String get dailySalesAmount => 'Маблағи фурӯши рӯзона';

  @override
  String get amountHint => 'мас. 5450.00';

  @override
  String get amountHelper => 'Маблағи умумии касса дар як рӯз бо ААИ';

  @override
  String get accountingDate => 'Санаи баҳисобгирӣ';

  @override
  String get balanceSplit => 'Тақсимоти пардохт';

  @override
  String get splitBalanced => 'Мутавозин';

  @override
  String get splitPos => 'POS > 80%';

  @override
  String get splitCash => 'Асосан нақд';

  @override
  String get notesLabel => 'Тавсиф / Қайдҳо ';

  @override
  String get optional => '(ихтиёрӣ)';

  @override
  String get notesHint => 'мас. мутобиқсозии нақд ва POS дар охири рӯз, аксия';

  @override
  String get saveSaleRecord => 'Сабтро нигоҳ доштан';

  @override
  String get syncsTo => '  Маълумот фавран ба REST-эндпоинт меравад ';

  @override
  String get saleFailed => 'Фурӯш сабт нашуд. Аз нав кӯшиш кунед.';

  @override
  String saleRecorded(String date) {
    return 'Фурӯш сабт шуд · $date';
  }

  @override
  String get storesEyebrow1 => 'Шабакаи мағозаҳо';

  @override
  String get storesEyebrow2 => 'Рӯйхати мағозаҳо';

  @override
  String get storesTitle => 'Идоракунии мағозаҳо';

  @override
  String get storesSubtitle => 'Филиалҳоро идора кунед, даромад ва ҳолати мағозаҳоро дар минтақаҳо пайгирӣ намоед.';

  @override
  String get exportDirectory => 'Содироти рӯйхат';

  @override
  String get addNewStore => 'Илова кардани мағоза';

  @override
  String get networkScope => 'Миқёси шабака';

  @override
  String nLocations(int count) {
    return '$count мағоза';
  }

  @override
  String opRatio(int pct) {
    return '$pct% фаъол';
  }

  @override
  String activeInactive(int active, int inactive) {
    return '$active фаъол · $inactive ғайрифаъол';
  }

  @override
  String get fleetVelocity => 'Фурӯши шабака имрӯз';

  @override
  String get allBranchesToday => 'ҳамаи филиалҳо имрӯз';

  @override
  String get totalMonthlyRevenue => 'Даромади моҳона';

  @override
  String get vsLastMonth => 'нисбат ба моҳи гузашта';

  @override
  String get allocatedWorkforce => 'Кормандони фаъол';

  @override
  String acrossBranches(int count) {
    return 'Дар $count филиал';
  }

  @override
  String get noStoresMatch => 'Мағоза аз рӯи филтр ёфт нашуд';

  @override
  String get monthlyVolume => 'Ҳаҷми моҳона';

  @override
  String allStatusCounts(int active, int inactive) {
    return 'Ҳамаи ҳолатҳо ($active фаъол, $inactive ғайрифаъол)';
  }

  @override
  String activeOnly(int count) {
    return 'Танҳо фаъол ($count)';
  }

  @override
  String inactiveOnly(int count) {
    return 'Танҳо ғайрифаъол ($count)';
  }

  @override
  String get allStatus => 'Ҳамаи ҳолатҳо';

  @override
  String get searchStores => 'Ҷустуҷӯ аз рӯи ном, шаҳр, телефон…';

  @override
  String sortBy(String label) {
    return 'Тартиб: $label';
  }

  @override
  String get sortRevenue => 'Аз рӯи даромад';

  @override
  String get sortName => 'Ном А–Я';

  @override
  String get grid => 'Шабака';

  @override
  String get list => 'Рӯйхат';

  @override
  String get deleteStoreTitle => 'Мағозаро нест кунем?';

  @override
  String deleteStoreBody(String name) {
    return '«$name» аз рӯйхат нест мешавад. Фурӯшҳои гузашта дар ҳисобот мемонанд.';
  }

  @override
  String storeDeleted(String name) {
    return '«$name» нест карда шуд';
  }

  @override
  String get deleteFailed => 'Мағоза нест нашуд';

  @override
  String get viewAnalytics => 'Таҳлил →';

  @override
  String vsYest(String pct) {
    return '$pct нисбат ба дирӯз';
  }

  @override
  String get offline => 'Хомӯш';

  @override
  String get topEarner => 'Пешсаф (#1)';

  @override
  String get staffHeadcount => 'Шумораи кормандон';

  @override
  String get reassigned => '0 (интиқол ёфтанд)';

  @override
  String nEmployees(int count) {
    return '$count корманд';
  }

  @override
  String get regionalTitle => 'Фурӯш аз рӯи минтақаҳо';

  @override
  String regionalSubtitle(String regions) {
    return 'Тақсимот аз рӯи минтақаҳо: $regions';
  }

  @override
  String get endpoint => 'Эндпоинт';

  @override
  String branchesCount(int count) {
    return '$count филиал';
  }

  @override
  String nInactive(int count) {
    return '$count ғайрифаъол';
  }

  @override
  String get capitalOutlets => 'Нуқтаҳои пойтахт';

  @override
  String get regionalTerritory => 'Минтақаҳо';

  @override
  String registersSynced(int count) {
    return '✓ Ҳамаи $count кассаи фаъол ҳамоҳанг шуданд';
  }

  @override
  String get opsLog => 'Дафтари амалиётҳо';

  @override
  String get noOperations => 'Ҳоло амалиёт нест';

  @override
  String get viewAuditTrail => 'Ҳамаи дафтар →';

  @override
  String get editStore => 'Таҳрири мағоза';

  @override
  String get storeName => 'Номи мағоза';

  @override
  String get storeType => 'Навъ (асосӣ, киоск…)';

  @override
  String get address => 'Суроға';

  @override
  String get region => 'Минтақа';

  @override
  String get enterPhone => 'Рақами телефонро ворид кунед';

  @override
  String get operatingHours => 'Соатҳои корӣ';

  @override
  String get storeOpen => 'Мағоза кушода аст (фаъол)';

  @override
  String get addStore => 'Илова кардан';

  @override
  String storeAdded(String name) {
    return '«$name» илова шуд';
  }

  @override
  String storeSaved(String name) {
    return '«$name» нигоҳ дошта шуд';
  }

  @override
  String get storeSaveFailed => 'Мағоза нигоҳ дошта нашуд. Аз нав кӯшиш кунед.';

  @override
  String get storeNotFound => 'Мағоза ёфт нашуд';

  @override
  String get dailySales => 'Фурӯши рӯзона';

  @override
  String get monthlyTotal => 'Ҳамагӣ дар моҳ';

  @override
  String get velocity7 => 'Фурӯш дар 7 рӯз';

  @override
  String avgPerDay(String amount) {
    return 'Миёна: $amount/рӯз';
  }

  @override
  String get sixDaysAgo => '6 рӯз пеш';

  @override
  String get todayCurrent => 'Имрӯз (ҷорӣ)';

  @override
  String get storeParams => 'Параметрҳои мағоза';

  @override
  String get phoneLine => 'Телефон:';

  @override
  String get staffAllocation => 'Кормандони филиал:';

  @override
  String activeCrew(int count) {
    return '$count корманди фаъол';
  }

  @override
  String get apiSync => 'REST API:';

  @override
  String get operatingHoursLabel => 'Соатҳои корӣ:';

  @override
  String get statusLabel => 'Ҳолат:';

  @override
  String get recentPos => 'Амалиётҳои охирини POS';

  @override
  String get noSalesYet => 'Ҳоло фурӯш нест';

  @override
  String get payrollEyebrow => 'Портали корхона';

  @override
  String fiscalYear(String year) {
    return 'СОЛИ МОЛИЯВИИ $year';
  }

  @override
  String ledger(String path) {
    return 'ДАФТАР $path';
  }

  @override
  String get payrollTitle => 'Идоракунии музди меҳнат';

  @override
  String get payrollSubtitle =>
      'Музди моҳонаи кормандонро идора кунед, пардохтҳоро сабт намоед ва қарзро дар ҳамаи филиалҳо пайгирӣ кунед.';

  @override
  String get exportLedger => 'Содироти дафтар';

  @override
  String get recordSalaryPayment => 'Сабти пардохти музд';

  @override
  String get totalMonthlyPayroll => 'Фонди музди моҳона';

  @override
  String get allocatedBudget => 'Буҷети моҳона';

  @override
  String get totalDisbursed => 'Пардохт шуд';

  @override
  String pctDisbursed(String pct) {
    return '$pct% пардохт шуд';
  }

  @override
  String get settled => 'Пардохтшуда';

  @override
  String get totalOutstanding => 'Қарзи боқимонда';

  @override
  String pctBalance(String pct) {
    return '$pct% боқимонда';
  }

  @override
  String get pendingClearance => 'Интизори пардохт';

  @override
  String get staffDistribution => 'Тақсимоти кормандон';

  @override
  String nBranches(int count) {
    return '$count филиал';
  }

  @override
  String get activeContracts => '100% шартномаҳои амалкунанда';

  @override
  String get colEmployee => 'Корманд ва вазифа';

  @override
  String get colAssignedStore => 'Мағоза';

  @override
  String get colTenure => 'Собиқа';

  @override
  String get colMonthlySalary => 'Маоши моҳона';

  @override
  String get colDisbursed => 'Пардохт шуд';

  @override
  String get colRemaining => 'Боқимонда';

  @override
  String get colStatus => 'Ҳолат';

  @override
  String get colActions => 'Амалҳо';

  @override
  String noPayrollFor(String month) {
    return 'Барои $month ҳоло музд нест';
  }

  @override
  String get noEmployeesMatch => 'Корманд аз рӯи филтр ёфт нашуд';

  @override
  String filteredBatch(String month) {
    return 'Давра: $month';
  }

  @override
  String get recordPayment => 'Пардохт кардан';

  @override
  String get history => 'Таърих';

  @override
  String get prevMonth => 'Моҳи гузашта';

  @override
  String get nextMonth => 'Моҳи оянда';

  @override
  String allStoresCount(int count) {
    return 'Ҳамаи мағозаҳо ($count)';
  }

  @override
  String get searchStaff => 'Ҷустуҷӯ аз рӯи ном ё вазифа…';

  @override
  String get tabAll => 'Ҳама';

  @override
  String get tabPaid => 'Пурра пардохт';

  @override
  String get tabPartial => 'Қисман';

  @override
  String get tabUnpaid => 'Пардохтнашуда';

  @override
  String get statusPaid => 'Пардохт шуд';

  @override
  String get statusPartial => 'Қисман';

  @override
  String get statusUnpaid => 'Пардохт нашуд';

  @override
  String tabCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String tenure(int count) {
    return '$count моҳ';
  }

  @override
  String get budgetTitle => 'Буҷет аз рӯи мағозаҳо';

  @override
  String get balanced => 'Мутавозин';

  @override
  String get openBalance => 'Қарз боқӣ';

  @override
  String get noPayrollMonth => 'Барои ин моҳ музд нест';

  @override
  String storeStaff(String store, int count) {
    return '$store ($count нафар)';
  }

  @override
  String get erpSynced => 'Бо дафтари асосии ERP ҳамоҳанг шуд';

  @override
  String get recentDisbursements => 'Пардохтҳои охирин';

  @override
  String get disbursementsSubtitle => 'Дафтари пардохтҳо дар ҳамаи филиалҳо';

  @override
  String get viewFullAudit => 'Ҳамаи дафтар →';

  @override
  String get noPaymentsMonth => 'Дар ин моҳ пардохт сабт нашудааст';

  @override
  String get bankNote => 'Ҳамаи интиқолҳои бонкӣ ба стандартҳои Бонки миллӣ мувофиқанд ва бо TLS ҳифз шудаанд.';

  @override
  String ledgerCopied(String month) {
    return 'Дафтари $month ҳамчун CSV нусха шуд';
  }

  @override
  String get methodBank => 'Интиқоли бонкӣ';

  @override
  String get methodCash => 'Пардохти нақд';

  @override
  String paidTo(String amount, String name) {
    return '$amount ба $name пардохт шуд';
  }

  @override
  String get paymentFailed => 'Пардохт нашуд. Аз нав кӯшиш кунед.';

  @override
  String get everyonePaid => 'Ҳама музди ин моҳро пурра гирифтанд.';

  @override
  String get employee => 'Корманд';

  @override
  String owed(String name, String amount) {
    return '$name — қарз $amount';
  }

  @override
  String salarySummary(String salary, String paid, String remaining) {
    return 'Маош $salary · пардохт $paid · боқимонда $remaining';
  }

  @override
  String maxAmount(String amount) {
    return 'Ҳадди аксар $amount';
  }

  @override
  String paymentsOf(String name) {
    return '$name — пардохтҳо';
  }

  @override
  String get paidBeforeRecords => 'Пеш аз сабт дар ин барнома пардохт шудааст.';

  @override
  String get employeesSubtitle => 'Кормандони ҳамаи мағозаҳо ва бастҳо';

  @override
  String get onShiftNow => 'Ҳозир дар баст';

  @override
  String get monthlyPayroll => 'Фонди музди моҳона';

  @override
  String get staffDirectory => 'Рӯйхати кормандон';

  @override
  String get noEmployees => 'Корманд ёфт нашуд';

  @override
  String get onShift => 'Дар баст';

  @override
  String get offShift => 'Истироҳат';

  @override
  String get analyzeMyReport => 'Ҳисоботи фурӯши маро таҳлил кун';

  @override
  String get reportsSubtitle => 'Натиҷаҳои моҳонаи мағозаҳо';

  @override
  String get analyzeWithAi => 'Таҳлил бо AI';

  @override
  String monthlySalesChange(String pct) {
    return 'Фурӯши моҳона ($pct)';
  }

  @override
  String get grossMarginShort => 'Фоидаи умумӣ';

  @override
  String get averagePerDay => 'Миёна дар як рӯз';

  @override
  String get salesByStore => 'Фурӯш аз рӯи мағозаҳо';

  @override
  String get monthlySalesCol => 'Фурӯши моҳона';

  @override
  String get email => 'Почтаи электронӣ';

  @override
  String get signOut => 'Баромадан';

  @override
  String get signOutNote => 'Воридшавӣ ва баромадан пас аз омода шудани авторизатсия дар сервер кор мекунанд.';

  @override
  String get business => 'Тиҷорат';

  @override
  String get businessName => 'Номи ширкат';

  @override
  String get currency => 'Асъор';

  @override
  String get backendConnection => 'Пайвастшавӣ ба сервер';

  @override
  String get demoData => 'Маълумоти намунавӣ';

  @override
  String get demoNote => 'То пайваст шудани эндпоинтҳои зерин сайт маълумоти намунавӣ нишон медиҳад.';

  @override
  String get askAssistant => 'Аз ёрдамчии тиҷоратӣ пурсед';

  @override
  String get assistantIntro =>
      'Дар бораи фурӯш, мағозаҳо, кормандон, музд ё маркетинг бо тоҷикӣ, русӣ ё англисӣ пурсед.';

  @override
  String get newChat => 'Чати нав';

  @override
  String get askHint => 'Дар бораи тиҷорататон пурсед…';

  @override
  String get send => 'Фиристодан';

  @override
  String get assistantError => 'Ёрдамчӣ ҷавоб надод. Аз нав кӯшиш кунед.';

  @override
  String get suggestSales => 'Фурӯши имрӯза';

  @override
  String get suggestStores => 'Беҳтарин мағозаҳо';

  @override
  String get suggestSalaries => 'Музди пардохтнашуда';

  @override
  String get suggestMarketing => 'Ғояҳои маркетинг';

  @override
  String chartRevenue(String amount) {
    return 'Даромад: $amount';
  }

  @override
  String chartCashflow(String amount) {
    return 'Гардиши пул: $amount';
  }

  @override
  String get loading => 'Бор шуда истодааст…';

  @override
  String get loginTitle => 'Хуш омадед';

  @override
  String get loginSubtitle => 'Барои идоракунии мағозаҳо, фурӯш ва музд ворид шавед.';

  @override
  String get registerTitle => 'Аккаунти тиҷоратӣ созед';

  @override
  String get registerSubtitle => 'Як аккаунт = як тиҷорат. Мағоза ва кормандонро пас аз сабт илова мекунед.';

  @override
  String get emailLabel => 'Почтаи электронӣ';

  @override
  String get password => 'Парол';

  @override
  String get fullName => 'Ному насаб';

  @override
  String get phoneOptional => 'Телефон (ихтиёрӣ)';

  @override
  String get businessNameOptional => 'Номи тиҷорат (ихтиёрӣ)';

  @override
  String get signIn => 'Ворид шудан';

  @override
  String get createAccount => 'Сохтани аккаунт';

  @override
  String get noAccount => 'Аккаунт надоред? Созед';

  @override
  String get haveAccount => 'Аккаунт доред? Ворид шавед';

  @override
  String get invalidEmail => 'Почтаи дурустро ворид кунед';

  @override
  String get invalidPhone => 'Телефон: 7–15 рақам, мас. +992901234567';

  @override
  String get errInvalidCredentials => 'Почта ё парол нодуруст аст.';

  @override
  String get errEmailTaken => 'Аккаунт бо ин почта аллакай ҳаст.';

  @override
  String get errAccountDisabled => 'Ин аккаунт хомӯш карда шудааст.';

  @override
  String get errAccountLocked => 'Кӯшишҳои нодуруст зиёд шуданд. Баъдтар кӯшиш кунед.';

  @override
  String get errSessionEnded => 'Сессия ба охир расид. Аз нав ворид шавед.';

  @override
  String get errPermission => 'Шумо барои ин амал иҷозат надоред.';

  @override
  String get errNotFound => 'Ёфт нашуд — шояд нест карда шудааст.';

  @override
  String get errConflict => 'Ин бо маълумоти мавҷуда мухолиф аст.';

  @override
  String errValidation(String fields) {
    return 'Майдонҳо нодурустанд: $fields';
  }

  @override
  String get errValidationShort => 'Майдонҳоро санҷед.';

  @override
  String get errNetwork => 'Бо сервер пайвастшавӣ нест. Интернетро санҷед ва аз нав кӯшиш кунед.';

  @override
  String get errRateLimited => 'Дархостҳо зиёданд. Каме сабр кунед.';

  @override
  String get errServer => 'Хатои сервер. Баъдтар кӯшиш кунед.';

  @override
  String get errStoreNameTaken => 'Мағоза бо ин ном аллакай ҳаст.';

  @override
  String get errStoreHasEmployees => 'Дар мағоза кормандони фаъол ҳастанд. Аввал онҳоро интиқол диҳед ё хомӯш кунед.';

  @override
  String get errAlreadyPaid => 'Музди ин моҳ аллакай пурра пардохт шудааст.';

  @override
  String get errExceedsRemaining => 'Маблағ аз боқимондаи ин моҳ зиёд аст.';

  @override
  String get errNotEmployed => 'Корманд дар ин моҳ кор накардааст.';

  @override
  String get errFutureDate => 'Сана наметавонад дар оянда бошад.';

  @override
  String get errFuturePeriod => 'Музди моҳи ояндаро пардохт кардан мумкин нест.';

  @override
  String get errEmploymentDates => 'Санаҳои кор нодурустанд.';

  @override
  String get errDateRange => 'Давра нодуруст аст.';

  @override
  String get errPasswordWeak => 'Парол хеле сода аст.';

  @override
  String get errCurrentPassword => 'Пароли ҳозира нодуруст аст.';

  @override
  String get errAvatarType => 'Акс бояд JPEG, PNG ё WebP бошад.';

  @override
  String get errAvatarSize => 'Акс хеле калон аст.';

  @override
  String errUnknown(String code) {
    return 'Хатогӣ рӯй дод ($code).';
  }

  @override
  String get description => 'Тавсиф';

  @override
  String get storeDescriptionHint => 'мас. мағозаи асосӣ · 8 касса';

  @override
  String get editSale => 'Таҳрири фурӯш';

  @override
  String get deleteSaleTitle => 'Ин фурӯшро нест кунем?';

  @override
  String deleteSaleBody(String amount, String store, String date) {
    return '$amount ($store, $date) аз ҳисобот нест мешавад.';
  }

  @override
  String get saleUpdated => 'Фурӯш таҳрир шуд';

  @override
  String get saleDeleted => 'Фурӯш нест карда шуд';

  @override
  String get colActionsShort => '';

  @override
  String get addEmployee => 'Илова кардани корманд';

  @override
  String get editEmployee => 'Таҳрири корманд';

  @override
  String get position => 'Вазифа';

  @override
  String get monthlySalary => 'Маоши моҳона (TJS)';

  @override
  String get hiredAt => 'Санаи қабул';

  @override
  String get terminatedAt => 'Санаи рафтан (ихтиёрӣ)';

  @override
  String get employeeActive => 'Корманд фаъол аст';

  @override
  String get deleteEmployeeTitle => 'Кормандро нест кунем?';

  @override
  String deleteEmployeeBody(String name) {
    return '«$name» пинҳон мешавад. Таърихи музд мемонад.';
  }

  @override
  String employeeSaved(String name) {
    return '«$name» нигоҳ дошта шуд';
  }

  @override
  String employeeDeleted(String name) {
    return '«$name» нест карда шуд';
  }

  @override
  String hiredThisMonth(int count) {
    return '$count нафар дар ин моҳ қабул шуд';
  }

  @override
  String get averageSalary => 'Маоши миёна';

  @override
  String get byPosition => 'Аз рӯи вазифа';

  @override
  String get selectStoreFirst => 'Аввал мағоза илова кунед';

  @override
  String get paymentDate => 'Санаи пардохт';

  @override
  String get noteOptional => 'Қайд (ихтиёрӣ)';

  @override
  String get paymentCancelled => 'Пардохт бекор карда шуд';

  @override
  String get cancelPayment => 'Бекор кардани пардохт';

  @override
  String get cancelPaymentTitle => 'Ин пардохтро бекор кунем?';

  @override
  String workedDays(int count) {
    return '$count рӯз';
  }

  @override
  String payFor(String month) {
    return 'Пардохт барои $month';
  }

  @override
  String owedAllMonths(String amount) {
    return 'Қарз дар ҳамаи моҳҳо: $amount';
  }

  @override
  String get months => 'Моҳҳо';

  @override
  String get payments => 'Пардохтҳо';

  @override
  String get noPaymentsYet => 'Ҳоло пардохт нест';

  @override
  String salesCount(int count) {
    return '$count фурӯш';
  }

  @override
  String chartSales(int count) {
    return 'Фурӯш: $count';
  }

  @override
  String get averageSale => 'Фурӯши миёна';

  @override
  String get salesThisMonth => 'Фурӯш дар ин моҳ';

  @override
  String get unpaidAllMonths => 'Пардохтнашуда (ҳамаи моҳҳо)';

  @override
  String ofTotal(int count) {
    return 'аз $count';
  }

  @override
  String ofDue(String amount) {
    return 'аз $amount';
  }

  @override
  String topStore(String name) {
    return 'Беҳтарин мағоза: $name';
  }

  @override
  String get noSalesThisMonth => 'Дар ин моҳ ҳоло фурӯш нест';

  @override
  String get recentlyUpdated => 'Мағозаҳои охирин тағйирёфта';

  @override
  String get salesShare => 'Ҳиссаи фурӯш дар ин моҳ';

  @override
  String updatedOn(String date) {
    return 'Тағйир: $date';
  }

  @override
  String get storeComparisonTitle => 'Муқоисаи мағозаҳо — ин моҳ';

  @override
  String payrollYearTitle(String year) {
    return 'Музди меҳнат дар $year';
  }

  @override
  String get colDue => 'Ҳисобшуда';

  @override
  String get colPaid => 'Пардохтшуда';

  @override
  String get colRemainingShort => 'Боқимонда';

  @override
  String get colChange => 'Тағйир';

  @override
  String get colSales => 'Фурӯш';

  @override
  String get colMonth => 'Моҳ';

  @override
  String get colEmployees => 'Кормандон';

  @override
  String get prevYear => 'Соли гузашта';

  @override
  String get nextYear => 'Соли оянда';

  @override
  String get editProfile => 'Таҳрири профил';

  @override
  String get saveChanges => 'Нигоҳ доштан';

  @override
  String get profileSaved => 'Профил нигоҳ дошта шуд';

  @override
  String get changePassword => 'Иваз кардани парол';

  @override
  String get currentPassword => 'Пароли ҳозира';

  @override
  String get newPassword => 'Пароли нав';

  @override
  String get passwordChanged => 'Парол иваз шуд';

  @override
  String get changePhoto => 'Иваз кардани акс';

  @override
  String get photoUpdated => 'Акс нав шуд';

  @override
  String get apiServer => 'Сервер';

  @override
  String get apiOnline => 'API пайваст аст';

  @override
  String get apiOffline => 'API дастрас нест';

  @override
  String get openDocs => 'Ҳуҷҷатҳои API (Swagger)';

  @override
  String signedInAs(String email) {
    return 'Шумо ҳамчун $email ворид шудед';
  }

  @override
  String get salesLast7 => 'Фурӯш — 7 рӯзи охир';

  @override
  String get storesReported => 'Мағозаҳо бо фурӯши имрӯза';

  @override
  String storesReportedValue(int count, int total) {
    return '$count аз $total мағоза';
  }

  @override
  String get assistantNote => 'Ҷавобҳо аз рақамҳои воқеии шумо сохта мешаванд, онҳоро AI дар сервер ҳисоб мекунад.';

  @override
  String get staffInStore => 'Кормандон';

  @override
  String get createdLabel => 'Сохта шуд:';

  @override
  String get addressLabel => 'Суроға:';

  @override
  String get searchEntries => 'Ҷустуҷӯ аз рӯи мағоза ё тавсиф…';

  @override
  String get today2 => 'Имрӯз';

  @override
  String noticeUnpaid(int count, String amount) {
    return 'Ба $count корманд музди ин моҳ ҳанӯз пардохт нашудааст · $amount TJS';
  }

  @override
  String noticeOverdue(int count, String amount) {
    return 'Музди дерпардохт: $count моҳи пардохтнашуда · $amount TJS';
  }

  @override
  String noticeNoSales(String store) {
    return '$store: имрӯз фурӯш нест';
  }

  @override
  String get navExpenses => 'Хароҷот';

  @override
  String get expensesSubtitle => 'Иҷора, коммуналӣ, расонидан ва дигар хароҷот — ва фоидае, ки мемонад';

  @override
  String get addExpense => 'Илова кардани хароҷот';

  @override
  String get editExpense => 'Тағйири хароҷот';

  @override
  String get expenseList => 'Ҳамаи хароҷот';

  @override
  String get expenseTotal => 'Ҳамагӣ';

  @override
  String get expenseDate => 'Сана';

  @override
  String get expenseAmount => 'Маблағ';

  @override
  String get expenseCategoryLabel => 'Категория';

  @override
  String get allCategories => 'Ҳамаи категорияҳо';

  @override
  String get wholeBusiness => 'Тамоми бизнес';

  @override
  String get expenseSaved => 'Хароҷот сабт шуд';

  @override
  String get expenseDeleted => 'Хароҷот нест карда шуд';

  @override
  String get deleteExpenseTitle => 'Ин хароҷот нест карда шавад?';

  @override
  String get deleteExpenseBody => 'Он дигар дар ҳисоботи фоида ҳисоб намешавад.';

  @override
  String get noExpenses => 'Ҳоло хароҷот нест';

  @override
  String get catRent => 'Иҷора';

  @override
  String get catUtilities => 'Хизматҳои коммуналӣ';

  @override
  String get catDelivery => 'Расонидан';

  @override
  String get catSupplies => 'Маводҳо';

  @override
  String get catMarketing => 'Маркетинг';

  @override
  String get catTaxes => 'Андозҳо';

  @override
  String get catOther => 'Дигар';

  @override
  String get profitThisMonth => 'Фоидаи ин моҳ';

  @override
  String get profitLabel => 'Фоида';

  @override
  String get salaryDueLabel => 'Музди ҳисобшуда';

  @override
  String get byCategory => 'Аз рӯи категория';

  @override
  String get profitByStore => 'Фоида аз рӯи мағоза';

  @override
  String get errExpenseNotFound => 'Ин хароҷот дигар вуҷуд надорад.';

  @override
  String get goalsTitle => 'Нақша ва фоида';

  @override
  String get weeklyTarget => 'Нақшаи фурӯши ҳафта';

  @override
  String get monthlyTarget => 'Нақшаи фурӯши моҳ';

  @override
  String get noTarget => 'Нақша муайян нашудааст';

  @override
  String get setTargets => 'Муайян кардани нақша';

  @override
  String get targetsSaved => 'Нақша сабт шуд';

  @override
  String get assistantThinking => 'Фикр мекунам…';

  @override
  String get loginHeadline => 'Ҳамаи мағозаҳо, фурӯш ва музди меҳнат дар як ҷо.';

  @override
  String get loginHeroBody => 'Аз ёрдамчӣ дар бораи рақамҳои худ пурсед. Ӯ бо тоҷикӣ, русӣ ё англисӣ ҷавоб медиҳад.';

  @override
  String get assistantLiveData => 'Аз рақамҳои воқеии шумо';

  @override
  String get askSales => 'Имрӯз чӣ қадар фурӯхтам?';

  @override
  String get askStores => 'Кадом мағоза дар ин моҳ беҳтар мефурӯшад?';

  @override
  String get askSalaries => 'Кӣ ҳанӯз музд нагирифтааст?';

  @override
  String get askMarketing => 'Ғояҳо барои ҷалби мизоҷони бештар';

  @override
  String get themeLabel => 'Намуди зоҳирӣ';

  @override
  String greeting(String name) {
    return 'Салом, $name';
  }

  @override
  String get greetingNoName => 'Салом';

  @override
  String get errSplitMismatch => 'Нақд ва корт якҷоя бояд ба маблағи фурӯш баробар бошанд.';

  @override
  String get clearDate => 'Тоза кардани сана';

  @override
  String get showPassword => 'Нишон додани парол';

  @override
  String get hidePassword => 'Пинҳон кардани парол';

  @override
  String get voiceSpeak => 'Бо овоз гуфтан';

  @override
  String get voiceStop => 'Қатъ кардан';

  @override
  String get voiceListening => 'Гӯш мекунам…';

  @override
  String voiceOpened(String section) {
    return 'Кушода шуд: $section';
  }

  @override
  String get voiceRepliesOn => 'Ҷавобҳоро бо овоз хондан: фаъол';

  @override
  String get voiceRepliesOff => 'Ҷавобҳоро бо овоз хондан: хомӯш';

  @override
  String get voiceStopSpeaking => 'Хонданро қатъ кардан';

  @override
  String get voiceHint => 'Микрофонро пахш кунед ва гӯед: «Фурӯшро кушо», «Чати нав» ё ягон савол.';

  @override
  String get voiceDenied => 'Дастрасӣ ба микрофон баста аст. Онро дар сатри суроғаи браузер иҷозат диҳед.';

  @override
  String get voiceNoSpeech => 'Ман чизе нашунидам. Боз кӯшиш кунед.';

  @override
  String get voiceNoMic => 'Микрофон ёфт нашуд.';

  @override
  String get voiceUnsupported => 'Ин браузер овозро намефаҳмад. Chrome ё Edge-ро истифода баред.';

  @override
  String get voiceNetwork => 'Барои фаҳмидани овоз интернет лозим аст.';

  @override
  String get voiceError => 'Вуруди овозӣ кор накард. Боз кӯшиш кунед.';

  @override
  String get chatHistory => 'Таърих';

  @override
  String get chatHistoryEmpty => 'Ҳоло чатҳои захирашуда нестанд. Савол диҳед — чат дар ин ҷо захира мешавад.';

  @override
  String get deleteChat => 'Нест кардани чат';

  @override
  String get deleteChatConfirm => 'Ин чатро нест кунем? Онро баргардондан намешавад.';

  @override
  String chatMessages(int count) {
    return '$count паём';
  }

  @override
  String get hideHistory => 'Пинҳон кардани таърих';

  @override
  String get showHistory => 'Нишон додани таърих';

  @override
  String get collapseMenu => 'Хурд кардани меню';

  @override
  String get expandMenu => 'Калон кардани меню';

  @override
  String get actionConfirm => 'Тасдиқ';

  @override
  String get actionDone => 'Иҷро шуд';

  @override
  String get actionCancelled => 'Бекор шуд';

  @override
  String get actionExpired => 'Мӯҳлат гузашт — боз пурсед';

  @override
  String get actionWaiting => 'Тасдиқи шумо лозим аст';

  @override
  String actionOpen(String section) {
    return 'Кушодан: $section';
  }

  @override
  String get actionDetails => 'Тафсилот';

  @override
  String get assistantSlow => 'Кор карда истодаам… ин то 30 сония вақт мегирад.';

  @override
  String get errActionNotFound => 'Ин амал дигар вуҷуд надорад.';

  @override
  String get errActionHandled => 'Ин амал аллакай иҷро ё бекор шудааст.';

  @override
  String assistantBusyWait(int seconds) {
    return 'Саволҳо зиёд шуданд. Баъди $seconds сония боз пурсед.';
  }

  @override
  String get assistantUnavailable => 'Ёрдамчӣ ҳоло дастрас нест. Баъдтар кӯшиш кунед.';

  @override
  String get actionAskAgain => 'Аз ёрдамчӣ боз пурсед';

  @override
  String get actionCancelledAsk => 'Бекор шуд — аз ёрдамчӣ боз пурсед';

  @override
  String get actionEdit => 'Тағйир додан';

  @override
  String get actionRetry => 'Боз тасдиқ';

  @override
  String get actionEditTitle => 'Пеш аз тасдиқ ислоҳ кунед';

  @override
  String get actionSaveConfirm => 'Захира ва тасдиқ';

  @override
  String get actionSureTitle => 'Боварӣ доред?';

  @override
  String actionSureBody(String summary) {
    return 'Ин нест карда мешавад:\n$summary';
  }

  @override
  String get colWorkedDays => 'Рӯзҳо дар моҳ';
}
