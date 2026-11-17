// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navDashboard => 'Панель';

  @override
  String get navStores => 'Магазины';

  @override
  String get navSales => 'Продажи';

  @override
  String get navEmployees => 'Сотрудники';

  @override
  String get navSalaries => 'Зарплаты';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navAssistant => 'ИИ-ассистент';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navMore => 'Ещё';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get close => 'Закрыть';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get loadError =>
      'Не удалось загрузить данные. Проверьте подключение и повторите.';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get noDataYet => 'Пока нет данных';

  @override
  String get today => 'Сегодня';

  @override
  String get active => 'Активен';

  @override
  String get inactive => 'Неактивен';

  @override
  String inactiveWithReason(String reason) {
    return 'Неактивен ($reason)';
  }

  @override
  String get store => 'Магазин';

  @override
  String get city => 'Город';

  @override
  String get status => 'Статус';

  @override
  String get phone => 'Телефон';

  @override
  String get staff => 'Персонал';

  @override
  String get name => 'Имя';

  @override
  String get role => 'Должность';

  @override
  String get shift => 'Смена';

  @override
  String get type => 'Тип';

  @override
  String get share => 'Доля';

  @override
  String get export => 'Экспорт';

  @override
  String get allStores => 'Все магазины';

  @override
  String get amountTjs => 'Сумма (TJS)';

  @override
  String get enterAmount => 'Введите сумму больше 0';

  @override
  String get required => 'Обязательное поле';

  @override
  String rowsCopied(int count) {
    return 'Скопировано строк: $count (CSV) — вставьте в Excel';
  }

  @override
  String get pagerPrev => '‹ Назад';

  @override
  String get pagerNext => 'Далее ›';

  @override
  String showingRange(int from, int to, int total) {
    return 'Показано $from–$to из $total';
  }

  @override
  String get language => 'Язык';

  @override
  String allStoresActive(int count) {
    return 'Все магазины ($count акт.)';
  }

  @override
  String get chooseStore => 'Выбрать магазин';

  @override
  String get searchHint => 'Поиск операций, магазинов, сотрудников…';

  @override
  String get demoBadge => 'Демо-данные · API не подключён';

  @override
  String get notifications => 'Уведомления';

  @override
  String salariesWaiting(int count) {
    return 'Ожидают выплаты: $count';
  }

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get businessOverview => 'Обзор бизнеса';

  @override
  String get liveAudit => 'LIVE-АУДИТ';

  @override
  String get overviewSubtitle =>
      'Сводные показатели всех филиалов и денежных потоков в реальном времени';

  @override
  String get recordSale => 'Записать продажу';

  @override
  String todayDate(String date) {
    return 'Сегодня: $date';
  }

  @override
  String get kpiTotalStores => 'Всего магазинов';

  @override
  String nActive(int count) {
    return '$count акт.';
  }

  @override
  String quarterNew(int count, int quarter) {
    return '+$count за $quarter кв.';
  }

  @override
  String ofRegistered(int count) {
    return 'из $count зарегистрированных';
  }

  @override
  String get kpiTotalStaff => 'Персонал';

  @override
  String nStaff(int count) {
    return '$count чел.';
  }

  @override
  String get onShiftToday => 'на смене сегодня';

  @override
  String get kpiTodaySales => 'Продажи сегодня';

  @override
  String get vsYesterday => 'к вчера';

  @override
  String get kpiWeeklySales => 'Продажи за неделю';

  @override
  String target(String value) {
    return 'Цель $value';
  }

  @override
  String get kpiMonthlySales => 'Продажи за месяц';

  @override
  String get mom => 'к прошлому месяцу';

  @override
  String get kpiUnpaidSalaries => 'Невыплаченные зарплаты';

  @override
  String nPending(int count) {
    return 'Ожидают: $count';
  }

  @override
  String cycle(String month) {
    return 'Цикл: $month';
  }

  @override
  String get revenueTitle => 'Аналитика выручки и денежного потока';

  @override
  String get revenueSubtitle => 'Динамика ежедневной выручки за текущий месяц';

  @override
  String get weekly => 'Неделя';

  @override
  String get monthly => 'Месяц';

  @override
  String peakLabel(String day, String amount) {
    return 'Пик: $day ($amount)';
  }

  @override
  String get peakShort => 'Пик';

  @override
  String get averageDaily => 'Среднее в день: ';

  @override
  String get totalVolume => 'Объём: ';

  @override
  String txns(String count) {
    return '$count опер.';
  }

  @override
  String autoReconciliation(String pct) {
    return '$pct% автоматической сверки';
  }

  @override
  String get grossMargin => 'Валовая маржа';

  @override
  String get onlineSplit => 'Доля онлайн / QR';

  @override
  String cardShare(String pct) {
    return '$pct% карта';
  }

  @override
  String get cashVaults => 'Наличные в сейфах';

  @override
  String get topStores => 'Лучшие магазины';

  @override
  String get ranked => 'Рейтинг';

  @override
  String get rankedSubtitle => 'По объёму продаж за месяц';

  @override
  String countersType(String type, int count) {
    return '$type • касс: $count';
  }

  @override
  String shareValue(String pct) {
    return 'Доля $pct%';
  }

  @override
  String viewAllStores(int count) {
    return 'Все магазины ($count)';
  }

  @override
  String get recentActivity => 'Последние события';

  @override
  String get liveFeed => 'ЛЕНТА';

  @override
  String get activitySubtitle =>
      'Финансовые проверки, закрытие касс и движение персонала в реальном времени';

  @override
  String get demoFeed => 'Демо-лента';

  @override
  String get syncActive => 'Синхронизация активна';

  @override
  String get filter => 'Фильтр';

  @override
  String get allActivity => 'Все события';

  @override
  String get activitySales => 'Продажи';

  @override
  String get activityPayroll => 'Зарплата';

  @override
  String get activityAudits => 'Проверки';

  @override
  String get activityStaff => 'Персонал';

  @override
  String get noActivity => 'Событий нет';

  @override
  String connectedTo(String endpoints) {
    return 'Подключено к $endpoints';
  }

  @override
  String get demoBackend => 'Демо-данные — сервер ещё не подключён';

  @override
  String get salesEyebrow => 'ФИНАНСОВЫЕ ОПЕРАЦИИ · ТАДЖИКИСТАН';

  @override
  String get salesTitle => 'Продажи и ежедневные записи';

  @override
  String get salesSubtitle =>
      'Записывайте дневной оборот магазинов в сомони (TJS) и следите за операциями в реальном времени.';

  @override
  String get totalToday => 'ИТОГО СЕГОДНЯ';

  @override
  String get totalThisMonth => 'ИТОГО ЗА МЕСЯЦ';

  @override
  String get successPrefix => 'Успешно: ';

  @override
  String saleSavedMessage(String amount, String store) {
    return 'Продажи на $amount записаны: $store.';
  }

  @override
  String get sessionClerk => 'Текущий оператор';

  @override
  String get authorized => 'Авторизован';

  @override
  String get storeLabel => 'Магазин:';

  @override
  String get searchReceipt => 'Поиск по № или заметкам…';

  @override
  String get updatedJustNow => 'Обновлено только что';

  @override
  String updatedMinutesAgo(int count) {
    return 'Обновлено $count мин назад';
  }

  @override
  String get activeFilterVolume => 'ОБЪЁМ ПО ФИЛЬТРУ';

  @override
  String get filteredTotal => 'Итого по фильтру: ';

  @override
  String acrossEntries(int count) {
    return '  записей: $count';
  }

  @override
  String vsPrevPeriod(String pct) {
    return '$pct к пред. периоду';
  }

  @override
  String get colDateTime => 'ДАТА И ВРЕМЯ';

  @override
  String get colStoreName => 'МАГАЗИН';

  @override
  String get colSalesAmount => 'СУММА ПРОДАЖ';

  @override
  String get colRegisteredBy => 'ЗАПИСАЛ';

  @override
  String get colNotesMethod => 'ЗАМЕТКИ / СПОСОБ';

  @override
  String get noEntries => 'Нет записей по фильтру';

  @override
  String get hourlyVelocity => 'Продажи по часам (сегодня)';

  @override
  String get reconciliation => 'Сверка';

  @override
  String storesSynced(int synced, int total) {
    return 'Сверено сегодня: $synced из $total';
  }

  @override
  String get rangeToday => 'Сегодня';

  @override
  String get rangeWeek => 'Эта неделя';

  @override
  String get rangeMonth => 'Этот месяц';

  @override
  String get rangeCustom => 'Период';

  @override
  String get newDailySale => 'Новая запись о продажах';

  @override
  String get posTerminal => 'POS-терминал';

  @override
  String get selectStore => 'Выберите магазин';

  @override
  String activeBranches(int count) {
    return 'Активных филиалов: $count';
  }

  @override
  String get dailySalesAmount => 'Сумма продаж за день';

  @override
  String get amountHint => 'напр. 5450.00';

  @override
  String get amountHelper => 'Общая сумма по кассе за день, включая НДС';

  @override
  String get accountingDate => 'Дата учёта';

  @override
  String get balanceSplit => 'Структура оплаты';

  @override
  String get splitBalanced => 'Поровну';

  @override
  String get splitPos => 'POS > 80%';

  @override
  String get splitCash => 'В основном наличные';

  @override
  String get notesLabel => 'Описание / Заметки ';

  @override
  String get optional => '(необязательно)';

  @override
  String get notesHint => 'напр. сверка наличных и POS в конце дня, акция';

  @override
  String get saveSaleRecord => 'Сохранить запись';

  @override
  String get syncsTo => '  Данные сразу уходят на REST-эндпоинт ';

  @override
  String get saleFailed => 'Не удалось сохранить продажу. Повторите.';

  @override
  String saleRecorded(String date) {
    return 'Продажа записана · $date';
  }

  @override
  String get storesEyebrow1 => 'СЕТЬ МАГАЗИНОВ';

  @override
  String get storesEyebrow2 => 'СПРАВОЧНИК';

  @override
  String get storesTitle => 'Управление магазинами';

  @override
  String get storesSubtitle =>
      'Управляйте филиалами, следите за выручкой и состоянием магазинов по регионам.';

  @override
  String get exportDirectory => 'Экспорт списка';

  @override
  String get addNewStore => 'Добавить магазин';

  @override
  String get networkScope => 'Масштаб сети';

  @override
  String nLocations(int count) {
    return '$count точек';
  }

  @override
  String opRatio(int pct) {
    return '$pct% работают';
  }

  @override
  String activeInactive(int active, int inactive) {
    return '$active акт. · $inactive неакт.';
  }

  @override
  String get fleetVelocity => 'Продажи сети сегодня';

  @override
  String get allBranchesToday => 'все филиалы сегодня';

  @override
  String get totalMonthlyRevenue => 'Выручка за месяц';

  @override
  String get vsLastMonth => 'к прошлому месяцу';

  @override
  String get allocatedWorkforce => 'Распределённый персонал';

  @override
  String acrossBranches(int count) {
    return 'Филиалов: $count';
  }

  @override
  String get noStoresMatch => 'Нет магазинов по фильтру';

  @override
  String get monthlyVolume => 'Объём за месяц';

  @override
  String allStatusCounts(int active, int inactive) {
    return 'Все статусы ($active акт., $inactive неакт.)';
  }

  @override
  String activeOnly(int count) {
    return 'Только активные ($count)';
  }

  @override
  String inactiveOnly(int count) {
    return 'Только неактивные ($count)';
  }

  @override
  String get allStatus => 'Все статусы';

  @override
  String get searchStores => 'Поиск по названию, городу, телефону…';

  @override
  String sortBy(String label) {
    return 'Сортировка: $label';
  }

  @override
  String get sortRevenue => 'По выручке';

  @override
  String get sortName => 'Название А–Я';

  @override
  String get grid => 'Сетка';

  @override
  String get list => 'Список';

  @override
  String get deleteStoreTitle => 'Удалить магазин?';

  @override
  String deleteStoreBody(String name) {
    return '«$name» будет удалён из списка. Прошлые продажи останутся в отчётах.';
  }

  @override
  String storeDeleted(String name) {
    return '«$name» удалён';
  }

  @override
  String get deleteFailed => 'Не удалось удалить магазин';

  @override
  String get viewAnalytics => 'Аналитика →';

  @override
  String vsYest(String pct) {
    return '$pct к вчера';
  }

  @override
  String get offline => 'Не работает';

  @override
  String get topEarner => 'Лидер продаж (#1)';

  @override
  String get staffHeadcount => 'Численность';

  @override
  String get reassigned => '0 (переведены)';

  @override
  String nEmployees(int count) {
    return '$count сотр.';
  }

  @override
  String get regionalTitle => 'Продажи по регионам';

  @override
  String regionalSubtitle(String regions) {
    return 'Разбивка по регионам: $regions';
  }

  @override
  String get endpoint => 'Эндпоинт';

  @override
  String branchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count филиалов',
      few: '$count филиала',
      one: '$count филиал',
    );
    return '$_temp0';
  }

  @override
  String nInactive(int count) {
    return '$count неакт.';
  }

  @override
  String get capitalOutlets => 'Столичные точки';

  @override
  String get regionalTerritory => 'Регионы';

  @override
  String registersSynced(int count) {
    return '✓ Все активные кассы ($count) синхронизированы';
  }

  @override
  String get opsLog => 'Журнал операций';

  @override
  String get noOperations => 'Пока нет операций';

  @override
  String get viewAuditTrail => 'Весь журнал →';

  @override
  String get editStore => 'Изменить магазин';

  @override
  String get storeName => 'Название магазина';

  @override
  String get storeType => 'Тип (флагман, киоск…)';

  @override
  String get address => 'Адрес';

  @override
  String get region => 'Регион';

  @override
  String get enterPhone => 'Введите номер телефона';

  @override
  String get operatingHours => 'Часы работы';

  @override
  String get storeOpen => 'Магазин работает';

  @override
  String get addStore => 'Добавить';

  @override
  String storeAdded(String name) {
    return '«$name» добавлен';
  }

  @override
  String storeSaved(String name) {
    return '«$name» сохранён';
  }

  @override
  String get storeSaveFailed => 'Не удалось сохранить магазин. Повторите.';

  @override
  String get storeNotFound => 'Магазин не найден';

  @override
  String get dailySales => 'За день';

  @override
  String get monthlyTotal => 'За месяц';

  @override
  String get velocity7 => 'Продажи за 7 дней';

  @override
  String avgPerDay(String amount) {
    return 'Ср.: $amount/день';
  }

  @override
  String get sixDaysAgo => '6 дней назад';

  @override
  String get todayCurrent => 'Сегодня';

  @override
  String get storeParams => 'Параметры магазина';

  @override
  String get phoneLine => 'Телефон:';

  @override
  String get staffAllocation => 'Персонал филиала:';

  @override
  String activeCrew(int count) {
    return '$count сотрудников';
  }

  @override
  String get apiSync => 'REST API:';

  @override
  String get operatingHoursLabel => 'Часы работы:';

  @override
  String get statusLabel => 'Статус:';

  @override
  String get recentPos => 'Последние операции POS';

  @override
  String get noSalesYet => 'Продаж пока нет';

  @override
  String get payrollEyebrow => 'КОРПОРАТИВНЫЙ ПОРТАЛ';

  @override
  String fiscalYear(String year) {
    return 'ФИНАНСОВЫЙ ГОД $year';
  }

  @override
  String ledger(String path) {
    return 'РЕЕСТР $path';
  }

  @override
  String get payrollTitle => 'Управление зарплатами';

  @override
  String get payrollSubtitle =>
      'Управляйте ежемесячными зарплатами, фиксируйте выплаты и следите за задолженностью по всем филиалам.';

  @override
  String get exportLedger => 'Экспорт реестра';

  @override
  String get recordSalaryPayment => 'Записать выплату';

  @override
  String get totalMonthlyPayroll => 'Фонд зарплаты';

  @override
  String get allocatedBudget => 'Месячный бюджет';

  @override
  String get totalDisbursed => 'Выплачено';

  @override
  String pctDisbursed(String pct) {
    return 'Выплачено $pct%';
  }

  @override
  String get settled => 'Погашено';

  @override
  String get totalOutstanding => 'Задолженность';

  @override
  String pctBalance(String pct) {
    return 'Остаток $pct%';
  }

  @override
  String get pendingClearance => 'Ожидает выплаты';

  @override
  String get staffDistribution => 'Распределение персонала';

  @override
  String nBranches(int count) {
    return 'Филиалов: $count';
  }

  @override
  String get activeContracts => '100% действующих договоров';

  @override
  String get colEmployee => 'СОТРУДНИК И ДОЛЖНОСТЬ';

  @override
  String get colAssignedStore => 'МАГАЗИН';

  @override
  String get colTenure => 'СТАЖ';

  @override
  String get colMonthlySalary => 'ОКЛАД';

  @override
  String get colDisbursed => 'ВЫПЛАЧЕНО';

  @override
  String get colRemaining => 'ОСТАТОК';

  @override
  String get colStatus => 'СТАТУС';

  @override
  String get colActions => 'ДЕЙСТВИЯ';

  @override
  String noPayrollFor(String month) {
    return 'За $month начислений нет';
  }

  @override
  String get noEmployeesMatch => 'Нет сотрудников по фильтру';

  @override
  String filteredBatch(String month) {
    return 'Период: $month';
  }

  @override
  String get recordPayment => 'Выплатить';

  @override
  String get history => 'История';

  @override
  String get prevMonth => 'Предыдущий месяц';

  @override
  String get nextMonth => 'Следующий месяц';

  @override
  String allStoresCount(int count) {
    return 'Все магазины ($count)';
  }

  @override
  String get searchStaff => 'Поиск по имени или должности…';

  @override
  String get tabAll => 'Все';

  @override
  String get tabPaid => 'Выплачено';

  @override
  String get tabPartial => 'Частично';

  @override
  String get tabUnpaid => 'Не выплачено';

  @override
  String get statusPaid => 'Выплачено';

  @override
  String get statusPartial => 'Частично';

  @override
  String get statusUnpaid => 'Не выплачено';

  @override
  String tabCount(String label, int count) {
    return '$label ($count)';
  }

  @override
  String tenure(int count) {
    return '$count мес.';
  }

  @override
  String get budgetTitle => 'Бюджет по магазинам';

  @override
  String get balanced => 'Сбалансировано';

  @override
  String get openBalance => 'Есть остаток';

  @override
  String get noPayrollMonth => 'Нет начислений за этот месяц';

  @override
  String storeStaff(String store, int count) {
    return '$store ($count чел.)';
  }

  @override
  String get erpSynced => 'Синхронизировано с главной книгой ERP';

  @override
  String get recentDisbursements => 'Последние выплаты';

  @override
  String get disbursementsSubtitle => 'Журнал выплат по всем филиалам';

  @override
  String get viewFullAudit => 'Весь журнал →';

  @override
  String get noPaymentsMonth => 'За этот месяц выплат нет';

  @override
  String get bankNote =>
      'Все банковские переводы соответствуют стандартам Нацбанка и защищены TLS.';

  @override
  String ledgerCopied(String month) {
    return 'Реестр за $month скопирован (CSV)';
  }

  @override
  String get methodBank => 'Банковский перевод';

  @override
  String get methodCash => 'Наличными';

  @override
  String paidTo(String amount, String name) {
    return 'Выплачено $amount: $name';
  }

  @override
  String get paymentFailed => 'Выплата не прошла. Повторите.';

  @override
  String get everyonePaid => 'Все получили зарплату за этот месяц.';

  @override
  String get employee => 'Сотрудник';

  @override
  String owed(String name, String amount) {
    return '$name — долг $amount';
  }

  @override
  String salarySummary(String salary, String paid, String remaining) {
    return 'Оклад $salary · выплачено $paid · остаток $remaining';
  }

  @override
  String maxAmount(String amount) {
    return 'Максимум $amount';
  }

  @override
  String paymentsOf(String name) {
    return '$name — выплаты';
  }

  @override
  String get paidBeforeRecords => 'Выплачено до начала учёта в приложении.';

  @override
  String get employeesSubtitle => 'Сотрудники всех магазинов и смен';

  @override
  String get onShiftNow => 'Сейчас на смене';

  @override
  String get monthlyPayroll => 'Фонд зарплаты';

  @override
  String get staffDirectory => 'Список сотрудников';

  @override
  String get noEmployees => 'Сотрудники не найдены';

  @override
  String get onShift => 'На смене';

  @override
  String get offShift => 'Не на смене';

  @override
  String get analyzeMyReport => 'Проанализируй мой отчёт о продажах';

  @override
  String get reportsSubtitle => 'Результаты магазинов за месяц';

  @override
  String get analyzeWithAi => 'Анализ с ИИ';

  @override
  String monthlySalesChange(String pct) {
    return 'Продажи за месяц ($pct)';
  }

  @override
  String get grossMarginShort => 'Валовая маржа';

  @override
  String get averagePerDay => 'В среднем за день';

  @override
  String get salesByStore => 'Продажи по магазинам';

  @override
  String get monthlySalesCol => 'За месяц';

  @override
  String get email => 'Эл. почта';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutNote =>
      'Вход и выход заработают после подключения авторизации на сервере.';

  @override
  String get business => 'Бизнес';

  @override
  String get businessName => 'Название компании';

  @override
  String get currency => 'Валюта';

  @override
  String get backendConnection => 'Подключение к серверу';

  @override
  String get demoData => 'Демо-данные';

  @override
  String get demoNote =>
      'Пока эндпоинты ниже не подключены, сайт показывает демо-данные.';

  @override
  String get askAssistant => 'Спросите бизнес-ассистента';

  @override
  String get assistantIntro =>
      'Продажи, магазины, персонал, зарплаты или маркетинг — спрашивайте на таджикском, русском или английском.';

  @override
  String get newChat => 'Новый чат';

  @override
  String get askHint => 'Спросите о своём бизнесе…';

  @override
  String get send => 'Отправить';

  @override
  String get assistantError => 'Ассистент не ответил. Повторите.';

  @override
  String get suggestSales => 'Продажи сегодня';

  @override
  String get suggestStores => 'Лучшие магазины';

  @override
  String get suggestSalaries => 'Невыплаченные зарплаты';

  @override
  String get suggestMarketing => 'Идеи маркетинга';

  @override
  String chartRevenue(String amount) {
    return 'Выручка: $amount';
  }

  @override
  String chartCashflow(String amount) {
    return 'Денежный поток: $amount';
  }
}
