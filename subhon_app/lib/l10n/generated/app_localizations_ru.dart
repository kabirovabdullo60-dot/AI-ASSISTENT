// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OFAR';

  @override
  String get introTitle => 'ИИ-бухгалтер';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonEmptyTitle => 'Пока пусто';

  @override
  String get commonErrorTitle => 'Не удалось загрузить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonClear => 'Очистить';

  @override
  String get commonShowMore => 'Показать ещё';

  @override
  String get commonNothingFound => 'Ничего не найдено.';

  @override
  String get fieldShowPassword => 'Показать пароль';

  @override
  String get fieldHidePassword => 'Скрыть пароль';

  @override
  String get navHome => 'Главная';

  @override
  String get navSales => 'Продажи';

  @override
  String get navPayroll => 'Зарплаты';

  @override
  String get navMore => 'Ещё';

  @override
  String get navAdd => 'Добавить';

  @override
  String get navStores => 'Магазины';

  @override
  String get navEmployees => 'Сотрудники';

  @override
  String get navReports => 'Отчёты';

  @override
  String get navProfile => 'Профиль и настройки';

  @override
  String get quickActionsTitle => 'Добавить';

  @override
  String get actionNewSale => 'Продажа';

  @override
  String get actionPaySalary => 'Выплата зарплаты';

  @override
  String get actionNewStore => 'Магазин';

  @override
  String get actionNewEmployee => 'Сотрудник';

  @override
  String get authLoginTitle => 'Вход';

  @override
  String get authLoginSubtitle =>
      'Войдите, чтобы продолжить работу с финансами компании';

  @override
  String get authRegisterTitle => 'Создайте аккаунт';

  @override
  String get authRegisterTab => 'Регистрация';

  @override
  String get authRegisterSubtitle =>
      'ИИ-бухгалтер для учёта доходов и расходов';

  @override
  String get fieldWorkEmail => 'Рабочий e-mail';

  @override
  String get authPasswordMinHint => 'Минимум 8 символов';

  @override
  String get validationPasswordMin => 'Минимум 8 символов';

  @override
  String get authNoAccount => 'Нет аккаунта?';

  @override
  String get authHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authCreateAccount => 'Зарегистрироваться';

  @override
  String get authSignInButton => 'Войти';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordHint => 'Введите пароль';

  @override
  String get authPasswordRepeat => 'Повторите пароль';

  @override
  String get authSignOut => 'Выйти из аккаунта';

  @override
  String get authSignOutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get authSignOutConfirmMessage =>
      'Чтобы войти снова, понадобятся e-mail и пароль.';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldEmailHint => 'name@company.tj';

  @override
  String get fieldFullName => 'Имя и фамилия';

  @override
  String get fieldBusinessName => 'Название бизнеса';

  @override
  String get fieldPhone => 'Телефон';

  @override
  String get fieldPhoneHint => '+992 90 123 45 67';

  @override
  String get fieldOptional => 'Необязательно';

  @override
  String get fieldStore => 'Магазин';

  @override
  String get fieldChooseStore => 'Выберите магазин';

  @override
  String get fieldStoreName => 'Название магазина';

  @override
  String get fieldAddress => 'Адрес';

  @override
  String get fieldDescription => 'Описание';

  @override
  String get fieldStatus => 'Статус';

  @override
  String get fieldAmount => 'Сумма';

  @override
  String get fieldDate => 'Дата';

  @override
  String get fieldPeriod => 'Период';

  @override
  String get fieldPosition => 'Должность';

  @override
  String get fieldMonthlySalary => 'Оклад в месяц';

  @override
  String get fieldHiredAt => 'Дата приёма';

  @override
  String get fieldTerminatedAt => 'Дата увольнения';

  @override
  String get fieldPaymentDate => 'Дата выплаты';

  @override
  String get fieldNote => 'Комментарий';

  @override
  String get validationRequired => 'Заполните поле';

  @override
  String get validationEmail => 'Введите корректный e-mail';

  @override
  String get validationPhone => 'От 7 до 15 цифр, можно начать с +';

  @override
  String get validationAmount =>
      'Введите сумму больше 0 (до 2 знаков после запятой)';

  @override
  String get validationPasswordsDiffer => 'Пароли не совпадают';

  @override
  String get statusActive => 'Работает';

  @override
  String get statusInactive => 'Не работает';

  @override
  String get homeMonthSales => 'Продажи за месяц';

  @override
  String get homeToday => 'Сегодня';

  @override
  String get homeWeek => 'За неделю';

  @override
  String get homeRevenueToday => 'Выручка за сегодня';

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodWeek => 'Неделя';

  @override
  String get periodMonth => 'Месяц';

  @override
  String get periodPrevious => 'Назад';

  @override
  String get periodNext => 'Вперёд';

  @override
  String get homePeriodSales => 'Продажи';

  @override
  String get homeAverageSale => 'Средняя продажа';

  @override
  String get homeNoComparison => 'Сравнить пока не с чем';

  @override
  String homeChange(String change, String compare) {
    return '$change $compare';
  }

  @override
  String get compareToday => 'к вчера';

  @override
  String get compareWeek => 'к прошлой неделе';

  @override
  String get compareMonth => 'к прошлому месяцу';

  @override
  String get homeSalaries => 'Зарплаты за месяц';

  @override
  String homeRemainingTotal(String amount) {
    return 'Не выплачено за все месяцы: $amount';
  }

  @override
  String get homeBusiness => 'Магазины и сотрудники';

  @override
  String homeOfTotal(int total) {
    return 'работают из $total';
  }

  @override
  String get homeTopStores => 'Лучшие магазины месяца';

  @override
  String get homeShowAll => 'Все продажи';

  @override
  String get homeNoSales => 'Продаж пока нет.';

  @override
  String salesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продажи',
      many: '$count продаж',
      few: '$count продажи',
      one: '$count продажа',
      zero: 'Нет продаж',
    );
    return '$_temp0';
  }

  @override
  String get salesTotal => 'Сумма продаж';

  @override
  String get salesAllStores => 'Все магазины';

  @override
  String get salesAllDates => 'За всё время';

  @override
  String get salesClearFilter => 'Сбросить фильтр';

  @override
  String get salesNothingFound => 'Нет продаж по этому фильтру.';

  @override
  String get salesEmptyTitle => 'Продаж пока нет';

  @override
  String get salesEmptyMessage => 'Добавьте первую продажу магазина.';

  @override
  String get saleNewTitle => 'Новая продажа';

  @override
  String get saleEditTitle => 'Продажа';

  @override
  String get saleNoStores => 'Сначала добавьте магазин';

  @override
  String get saleSaved => 'Продажа добавлена';

  @override
  String get saleUpdated => 'Продажа изменена';

  @override
  String get saleDeleted => 'Продажа удалена';

  @override
  String get saleDeleteTitle => 'Удалить продажу?';

  @override
  String get saleDeleteMessage =>
      'Она больше не будет учитываться в продажах и отчётах.';

  @override
  String get storesSearch => 'Поиск по названию или адресу';

  @override
  String get storesEmptyTitle => 'Магазинов пока нет';

  @override
  String get storesEmptyMessage =>
      'Добавьте первый магазин, чтобы вести его продажи.';

  @override
  String get storeNewTitle => 'Новый магазин';

  @override
  String get storeEditTitle => 'Изменить магазин';

  @override
  String get storeSaved => 'Магазин сохранён';

  @override
  String get storeDeleted => 'Магазин удалён. Его продажи остаются в отчётах.';

  @override
  String get storeDeleteTitle => 'Удалить магазин?';

  @override
  String get storeDeleteMessage =>
      'История продаж сохранится. Магазин с работающими сотрудниками удалить нельзя.';

  @override
  String get storeLatestSales => 'Последние продажи';

  @override
  String get storeNoEmployees => 'В этом магазине нет сотрудников.';

  @override
  String get employeesSearch => 'Поиск по имени или телефону';

  @override
  String get employeesActive => 'Работают';

  @override
  String get employeesSalaryFund => 'Фонд оплаты в месяц';

  @override
  String employeesAverage(String amount) {
    return 'В среднем $amount';
  }

  @override
  String get employeesEmptyTitle => 'Сотрудников пока нет';

  @override
  String get employeesEmptyMessage =>
      'Добавьте сотрудников, чтобы вести их зарплаты.';

  @override
  String get employeeNewTitle => 'Новый сотрудник';

  @override
  String get employeeEditTitle => 'Сотрудник';

  @override
  String get employeeSaved => 'Сотрудник сохранён';

  @override
  String get employeeDeleted => 'Сотрудник удалён. История зарплат сохранена.';

  @override
  String get employeeDeleteTitle => 'Удалить сотрудника?';

  @override
  String get employeeDeleteMessage => 'История зарплат сохранится.';

  @override
  String get payrollPaid => 'Выплачено';

  @override
  String get payrollPartial => 'Частично';

  @override
  String get payrollUnpaid => 'Не выплачено';

  @override
  String get payrollDue => 'К выплате';

  @override
  String get payrollDueTotal => 'Начислено всего';

  @override
  String get payrollPaidAmount => 'Выплачено';

  @override
  String get payrollRemaining => 'Осталось выплатить';

  @override
  String payrollCounts(int paid, int partial, int unpaid) {
    return 'Выплачено $paid · частично $partial · не выплачено $unpaid';
  }

  @override
  String payrollLeft(String amount) {
    return 'осталось $amount';
  }

  @override
  String get payrollEmptyTitle => 'Зарплат за этот месяц нет';

  @override
  String get payrollEmptyMessage =>
      'Здесь появятся сотрудники, работавшие в этом месяце.';

  @override
  String get payrollHistory => 'История зарплаты';

  @override
  String get payrollMonths => 'По месяцам';

  @override
  String get payrollPayments => 'Выплаты';

  @override
  String get payrollNoPayments => 'Выплат пока нет.';

  @override
  String payrollPaidOf(String paid, String due) {
    return '$paid из $due';
  }

  @override
  String payrollPaidSoFar(String amount) {
    return 'Выплачено $amount';
  }

  @override
  String payrollMonthlySalary(String amount) {
    return 'Оклад $amount в месяц';
  }

  @override
  String payrollWorkedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня работы',
      many: '$count дней работы',
      few: '$count дня работы',
      one: '$count день работы',
    );
    return '$_temp0';
  }

  @override
  String payrollMonthsWorked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String get paymentTitle => 'Выплата зарплаты';

  @override
  String get paymentSubmit => 'Выплатить';

  @override
  String get paymentSaved => 'Выплата записана';

  @override
  String get paymentAlreadyPaid => 'Этот месяц уже выплачен полностью.';

  @override
  String paymentFor(String period) {
    return 'за $period';
  }

  @override
  String get paymentCancel => 'Отменить';

  @override
  String get paymentCancelTitle => 'Отменить выплату?';

  @override
  String paymentCancelMessage(String amount) {
    return '$amount снова будет считаться невыплаченной суммой.';
  }

  @override
  String get paymentCancelled => 'Выплата отменена';

  @override
  String get reportStores => 'Магазины за месяц';

  @override
  String reportStoresPeriod(String start, String end) {
    return 'Продажи $start – $end';
  }

  @override
  String get reportPayroll => 'Зарплаты за год';

  @override
  String get reportEmployees => 'Сотрудники по магазинам и должностям';

  @override
  String reportEmployeesCount(int active, int total) {
    return 'работают $active из $total';
  }

  @override
  String get moreBusiness => 'Бизнес';

  @override
  String get moreAccount => 'Аккаунт';

  @override
  String get moreStoresHint => 'Добавление, правка, продажи и сотрудники';

  @override
  String get moreEmployeesHint => 'Сотрудники, должности и оклады';

  @override
  String get moreReportsHint => 'Сравнение магазинов, зарплаты за год';

  @override
  String get profileEdit => 'Изменить профиль';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get profileChangePhoto => 'Сменить фото';

  @override
  String get profileAvatarSaved => 'Фото обновлено';

  @override
  String get profileDetails => 'Бизнес и контакты';

  @override
  String get profileSettings => 'Настройки';

  @override
  String get profileCurrency => 'Валюта';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLanguageSystem => 'Как на телефоне';

  @override
  String get profileNotSet => 'Не указано';

  @override
  String get passwordTitle => 'Сменить пароль';

  @override
  String get passwordCurrent => 'Текущий пароль';

  @override
  String get passwordNew => 'Новый пароль';

  @override
  String get passwordNote =>
      'На других устройствах выполнится выход. Здесь вы останетесь в аккаунте.';

  @override
  String get passwordChanged => 'Пароль изменён';

  @override
  String get errNetwork =>
      'Нет связи с сервером. Проверьте интернет и повторите.';

  @override
  String get errInvalidCredentials => 'Неверный e-mail или пароль.';

  @override
  String get errAccountLocked =>
      'Слишком много попыток. Повторите через 15 минут.';

  @override
  String get errAccountDisabled => 'Этот аккаунт отключён.';

  @override
  String get errSessionEnded => 'Сеанс завершён. Войдите снова.';

  @override
  String get errEmailTaken => 'Аккаунт с таким e-mail уже есть.';

  @override
  String get errPasswordWeak =>
      'Слишком простой пароль. Используйте более длинный, с буквами и цифрами.';

  @override
  String get errCurrentPassword => 'Текущий пароль указан неверно.';

  @override
  String get errAvatarTooLarge => 'Фото слишком большое (не больше 5 МБ).';

  @override
  String get errAvatarType => 'Выберите фото JPEG, PNG или WebP.';

  @override
  String get errStoreNotFound => 'Магазин не найден. Возможно, он удалён.';

  @override
  String get errStoreNameTaken => 'Магазин с таким названием уже есть.';

  @override
  String get errStoreHasEmployees =>
      'В магазине есть работающие сотрудники. Сначала переведите их в другой магазин или отметьте как неработающих.';

  @override
  String get errSaleNotFound => 'Продажа не найдена. Возможно, она удалена.';

  @override
  String get errSaleDateFuture => 'Дата продажи не может быть в будущем.';

  @override
  String get errEmployeeNotFound => 'Сотрудник не найден. Возможно, он удалён.';

  @override
  String get errEmploymentDates =>
      'Дата увольнения должна быть позже даты приёма.';

  @override
  String get errNotEmployedInPeriod => 'Сотрудник не работал в этом месяце.';

  @override
  String get errPaymentNotFound =>
      'Выплата не найдена. Возможно, она отменена.';

  @override
  String get errPayrollExceeds =>
      'Сумма больше, чем осталось выплатить за этот месяц.';

  @override
  String get errPayrollAlreadyPaid => 'Этот месяц уже выплачен полностью.';

  @override
  String get errPayrollFuture => 'Будущий месяц пока нельзя выплатить.';

  @override
  String get errPaymentDateFuture => 'Дата выплаты не может быть в будущем.';

  @override
  String get errDateRange => 'Начало периода не может быть позже конца.';

  @override
  String get errValidation =>
      'Некоторые поля заполнены неверно. Проверьте их и повторите.';

  @override
  String get errPermission => 'У вас нет прав на это действие.';

  @override
  String get errNotFound => 'Не найдено. Возможно, запись удалена.';

  @override
  String get errConflict =>
      'Конфликт с текущими данными. Обновите и повторите.';

  @override
  String get errRateLimited =>
      'Слишком много запросов. Подождите немного и повторите.';

  @override
  String get errServer => 'Сервер работает с ошибкой. Повторите позже.';

  @override
  String get errUnknown => 'Что-то пошло не так. Повторите.';

  @override
  String get navExpenses => 'Расходы';

  @override
  String get moreExpensesHint => 'Аренда, коммуналка, доставка и другое';

  @override
  String get actionNewExpense => 'Расход';

  @override
  String get fieldCategory => 'Категория';

  @override
  String get expenseCategoryRent => 'Аренда';

  @override
  String get expenseCategoryUtilities => 'Коммунальные услуги';

  @override
  String get expenseCategoryDelivery => 'Доставка';

  @override
  String get expenseCategorySupplies => 'Расходники';

  @override
  String get expenseCategoryMarketing => 'Реклама';

  @override
  String get expenseCategoryTaxes => 'Налоги';

  @override
  String get expenseCategoryOther => 'Другое';

  @override
  String get expensesAllCategories => 'Все категории';

  @override
  String get expenseWholeBusiness => 'Весь бизнес';

  @override
  String get expensesTotal => 'Сумма расходов';

  @override
  String expensesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расхода',
      many: '$count расходов',
      few: '$count расхода',
      one: '$count расход',
      zero: 'Нет расходов',
    );
    return '$_temp0';
  }

  @override
  String get expensesNothingFound => 'Нет расходов по этому фильтру.';

  @override
  String get expensesEmptyTitle => 'Расходов пока нет';

  @override
  String get expensesEmptyMessage =>
      'Записывайте аренду, коммуналку и другие траты, чтобы видеть настоящую прибыль.';

  @override
  String get expenseNewTitle => 'Новый расход';

  @override
  String get expenseEditTitle => 'Расход';

  @override
  String get expenseSaved => 'Расход добавлен';

  @override
  String get expenseUpdated => 'Расход изменён';

  @override
  String get expenseDeleted => 'Расход удалён';

  @override
  String get expenseDeleteTitle => 'Удалить расход?';

  @override
  String get expenseDeleteMessage =>
      'Он больше не будет учитываться в расходах и прибыли.';

  @override
  String get errExpenseNotFound => 'Этот расход больше не существует.';

  @override
  String get errExpenseDateFuture => 'Дата расхода не может быть в будущем.';

  @override
  String get reportProfit => 'Прибыль';

  @override
  String get profitSales => 'Продажи';

  @override
  String get profitExpenses => 'Расходы';

  @override
  String get profitSalaryDue => 'Зарплаты начислено';

  @override
  String profitMargin(String percent) {
    return 'Маржа $percent';
  }

  @override
  String get profitNoSales => 'В этом периоде нет продаж';

  @override
  String get profitByCategory => 'Расходы по категориям';

  @override
  String get profitByStore => 'Прибыль по магазинам';

  @override
  String get profitNoExpenses => 'Расходов за этот период нет.';

  @override
  String profitStoreLine(String sales, String expenses, String salary) {
    return 'Продажи $sales · расходы $expenses · зарплаты $salary';
  }

  @override
  String get homeTargetsProfit => 'Цели и прибыль';

  @override
  String get homeMonthProfit => 'Прибыль за месяц';

  @override
  String homeProfitCaption(String expenses, String margin) {
    return 'Расходы $expenses · $margin';
  }

  @override
  String get targetWeek => 'Цель на неделю';

  @override
  String get targetMonth => 'Цель на месяц';

  @override
  String get targetNotSet => 'Задать цель';

  @override
  String targetDone(String percent) {
    return 'Выполнено $percent';
  }

  @override
  String get targetSheetTitleWeek => 'Цель продаж на неделю';

  @override
  String get targetSheetTitleMonth => 'Цель продаж на месяц';

  @override
  String get targetSheetHint =>
      'Для всего бизнеса. Можно изменить в любой момент.';

  @override
  String get targetSaved => 'Цель сохранена';

  @override
  String get activityTitle => 'Последние действия';

  @override
  String get activityLogTitle => 'Журнал операций';

  @override
  String get activityEmpty => 'Изменений пока нет.';

  @override
  String activityStoreCreated(String name) {
    return 'Добавлен магазин «$name»';
  }

  @override
  String activityStoreUpdated(String name) {
    return 'Изменён магазин «$name»';
  }

  @override
  String activityStoreDeleted(String name) {
    return 'Удалён магазин «$name»';
  }

  @override
  String activityStoreStatus(String name, String status) {
    return 'Магазин «$name»: $status';
  }

  @override
  String activitySaleCreated(String name) {
    return 'Продажа в «$name»';
  }

  @override
  String activitySaleUpdated(String name) {
    return 'Изменена продажа в «$name»';
  }

  @override
  String activitySaleDeleted(String name) {
    return 'Удалена продажа в «$name»';
  }

  @override
  String activityEmployeeCreated(String name) {
    return 'Добавлен сотрудник $name';
  }

  @override
  String activityEmployeeUpdated(String name) {
    return 'Изменены данные: $name';
  }

  @override
  String activityEmployeeDeleted(String name) {
    return 'Удалён сотрудник $name';
  }

  @override
  String activityEmployeeStatus(String name, String status) {
    return '$name: $status';
  }

  @override
  String activityPayrollPaid(String name) {
    return 'Выплачена зарплата: $name';
  }

  @override
  String activityPayrollCancelled(String name) {
    return 'Отменена выплата: $name';
  }

  @override
  String get activityProfileUpdated => 'Профиль изменён';

  @override
  String activityOther(String name) {
    return '$name: изменение';
  }

  @override
  String activityBy(String actor, String time) {
    return '$actor · $time';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsTooltip => 'Уведомления';

  @override
  String get notificationsEmpty => 'Всё в порядке: ничего не требует внимания.';

  @override
  String get notificationsNew => 'Новое';

  @override
  String get notifSalaryOverdueTitle => 'Просроченная зарплата';

  @override
  String notifSalaryOverdueBody(int count, String amount) {
    return 'Не выплачено за прошлые месяцы ($count) · $amount';
  }

  @override
  String get notifUnpaidTitle => 'Зарплата за этот месяц';

  @override
  String notifUnpaidBody(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось выплатить $count сотрудникам',
      one: 'Осталось выплатить 1 сотруднику',
    );
    return '$_temp0 · $amount';
  }

  @override
  String get notifNoSalesTitle => 'Сегодня нет продаж';

  @override
  String notifNoSalesBody(String store) {
    return 'В «$store» сегодня не записано ни одной продажи.';
  }

  @override
  String get notifOther => 'Требует внимания';

  @override
  String get assistantTitle => 'ИИ-ассистент';

  @override
  String get moreAssistantHint => 'Спросите о продажах, магазинах и зарплатах';

  @override
  String get assistantIntro =>
      'Спросите меня о своих деньгах или о бизнесе — я отвечу по вашим настоящим цифрам.';

  @override
  String get assistantHint => 'Ваш вопрос…';

  @override
  String get assistantSend => 'Отправить';

  @override
  String get assistantThinking => 'Думаю…';

  @override
  String get assistantSuggestToday => 'Как продажи сегодня?';

  @override
  String get assistantSuggestBestStore => 'Какой магазин продаёт лучше всех?';

  @override
  String get assistantSuggestSalary => 'Сколько зарплаты ещё не выплачено?';

  @override
  String get errAssistantUnavailable =>
      'Ассистент сейчас недоступен. Попробуйте позже.';

  @override
  String errAssistantRateLimited(int seconds) {
    return 'Слишком много вопросов. Подождите $seconds с и попробуйте снова.';
  }

  @override
  String get fieldPaymentMethod => 'Способ оплаты';

  @override
  String get paymentNotSet => 'Не указан';

  @override
  String get paymentCash => 'Наличные';

  @override
  String get paymentCard => 'Карта';

  @override
  String get paymentQr => 'QR-код';

  @override
  String get paymentMixed => 'Наличные + карта';

  @override
  String get fieldCashAmount => 'Из них наличными';

  @override
  String get fieldCardAmount => 'Из них картой';

  @override
  String get fieldReceiptNumber => 'Номер чека';

  @override
  String get validationSplit =>
      'Наличные и карта вместе должны равняться сумме';

  @override
  String get errSaleSplit => 'Наличные и карта вместе должны равняться сумме.';

  @override
  String get homeByPayment => 'По способам оплаты';

  @override
  String get fieldCity => 'Город';

  @override
  String get fieldRegion => 'Регион';

  @override
  String get fieldRegionHint => 'Душанбе, Согд, Хатлон, ГБАО, РРП';

  @override
  String get fieldStoreType => 'Формат';

  @override
  String get fieldStoreTypeHint => 'Супермаркет, киоск…';

  @override
  String get fieldCounters => 'Кассы';

  @override
  String get fieldOpeningHours => 'Часы работы';

  @override
  String get fieldOpeningHoursHint => '09:00–21:00';

  @override
  String get fieldStatusNote => 'Причина статуса';

  @override
  String get fieldStatusNoteHint => 'Например, ремонт';

  @override
  String get validationCounters => 'Целое число от 0 до 999';

  @override
  String get storeMoreDetails => 'Подробнее';

  @override
  String get fieldSalaryMethod => 'Способ выплаты';

  @override
  String get salaryMethodBank => 'Банковский перевод';

  @override
  String get salaryMethodCash => 'Наличные';

  @override
  String get payrollAllTimeRemaining => 'Невыплачено за все месяцы';

  @override
  String payrollAllTimeCaption(String due, String paid) {
    return 'Начислено $due · выплачено $paid';
  }

  @override
  String get reportByRegion => 'По регионам';

  @override
  String get reportNoRegion => 'Без региона';

  @override
  String reportRegionStores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count магазина',
      many: '$count магазинов',
      few: '$count магазина',
      one: '$count магазин',
    );
    return '$_temp0';
  }

  @override
  String get homeTodaySales => 'Продажи за сегодня';

  @override
  String get homeMonth => 'За месяц';

  @override
  String get storeTargets => 'Цели магазина';

  @override
  String get targetSheetHintStore =>
      'Только для этого магазина. Можно изменить в любой момент.';

  @override
  String get activityHistory => 'История';

  @override
  String get voiceTitle => 'Голосом';

  @override
  String get voiceOpen => 'Говорить голосом';

  @override
  String get voiceListening => 'Слушаю…';

  @override
  String get voiceSpeaking => 'Отвечаю…';

  @override
  String get voiceTapToTalk => 'Нажмите на микрофон и говорите';

  @override
  String get voiceHint =>
      'Спросите что угодно: «сотрудники», «продажи сегодня», «сколько осталось выплатить?»';

  @override
  String get voiceMic => 'Говорить';

  @override
  String get voiceEnd => 'Завершить';

  @override
  String get voiceUnavailable =>
      'Распознавание речи недоступно. Разрешите микрофон и распознавание речи в Настройках.';

  @override
  String get voiceMicFailed =>
      'Микрофон не включился. Попробуйте ещё раз; если повторяется — проверьте доступ к микрофону в Настройках.';

  @override
  String get chatHistory => 'История чатов';

  @override
  String get chatNew => 'Новый чат';

  @override
  String get chatHistoryEmpty =>
      'Здесь будут сохраняться ваши разговоры с ассистентом.';

  @override
  String get chatDeleteAll => 'Удалить все';

  @override
  String get chatDeleteAllTitle => 'Удалить все чаты?';

  @override
  String get chatDeleteAllMessage =>
      'История хранится только на этом телефоне, вернуть её не получится.';

  @override
  String get chatDeleted => 'Чат удалён';

  @override
  String get chatCurrent => 'Открыт сейчас';

  @override
  String homeStores(int count) {
    return 'Магазины · $count';
  }

  @override
  String get homeStoreMonth => 'За месяц';

  @override
  String get homeAddStore => 'Добавить магазин';

  @override
  String get homeProfit => 'Прибыль';

  @override
  String get homeShowAllStores => 'Все';

  @override
  String historyExpensesFor(String month) {
    return 'Расходы за $month';
  }

  @override
  String historyOfSales(String percent) {
    return '$percent от продаж';
  }

  @override
  String get historyStatement => 'Выписка';

  @override
  String get historyShowAmount => 'Показать сумму';

  @override
  String get historyHideAmount => 'Скрыть сумму';

  @override
  String get historySearch => 'Поиск';

  @override
  String get historySearchHint => 'Магазин, сотрудник или комментарий';

  @override
  String get historyAll => 'Все';

  @override
  String get historyYesterday => 'Вчера';

  @override
  String get historyWeek => 'Неделя';

  @override
  String get historyNothing => 'За этот период операций нет.';

  @override
  String get opSale => 'Продажа';

  @override
  String get opSaleEdited => 'Продажа изменена';

  @override
  String get opSaleDeleted => 'Продажа удалена';

  @override
  String get opSalary => 'Выплата зарплаты';

  @override
  String get opSalaryCancelled => 'Выплата отменена';

  @override
  String get opStoreNew => 'Новый магазин';

  @override
  String get opStoreEdited => 'Магазин изменён';

  @override
  String get opStoreDeleted => 'Магазин удалён';

  @override
  String get opEmployeeNew => 'Новый сотрудник';

  @override
  String get opEmployeeEdited => 'Сотрудник изменён';

  @override
  String get opEmployeeDeleted => 'Сотрудник удалён';

  @override
  String opStatus(String status) {
    return 'Статус: $status';
  }

  @override
  String get opProfile => 'Профиль изменён';

  @override
  String get opOther => 'Изменение';

  @override
  String get stmtTitle => 'Выписки и справки';

  @override
  String get stmtAvailable => 'Доступные';

  @override
  String get stmtMine => 'Мои выписки';

  @override
  String get stmtCertificates => 'Справки';

  @override
  String get stmtStatements => 'Выписки';

  @override
  String get stmtForPeriod => 'Все операции за период';

  @override
  String get stmtSales => 'По продажам';

  @override
  String get stmtStore => 'По магазину';

  @override
  String get stmtStoreHint => 'Продажи одного магазина за период';

  @override
  String get stmtCash => 'Наличные';

  @override
  String get stmtCashHint => 'Только наличные, смешанные оплаты разделены';

  @override
  String get stmtCard => 'Карта и QR';

  @override
  String get stmtCardHint => 'Только безналичные оплаты';

  @override
  String get stmtExpenses => 'По расходам';

  @override
  String get stmtSalaries => 'По выплатам зарплаты';

  @override
  String get stmtOperations => 'Все операции';

  @override
  String get stmtOperationsHint => 'Каждое изменение в бизнесе';

  @override
  String get stmtSalaryDebt => 'Кому должны по зарплате';

  @override
  String get stmtSalaryDebtHint =>
      'Сотрудники с невыплаченной зарплатой на сегодня';

  @override
  String get stmtProfit => 'О прибыли';

  @override
  String get stmtProfitHint => 'Продажи − расходы − зарплаты за период';

  @override
  String get stmtStores => 'Сводка по магазинам';

  @override
  String get stmtStoresHint => 'Магазины по продажам';

  @override
  String get stmtMineEmpty =>
      'Здесь сохраняются выписки, которые вы открывали.';

  @override
  String get stmtPeriodLastMonth => 'Прошлый месяц';

  @override
  String get stmtPeriodCustom => 'Выбрать даты';

  @override
  String get stmtChooseStore => 'Выберите магазин';

  @override
  String stmtAsOf(String date) {
    return 'На $date';
  }

  @override
  String get stmtEmpty => 'За этот период ничего нет.';

  @override
  String get stmtTruncated =>
      'Слишком много строк: показаны самые новые. Выберите период короче.';

  @override
  String get stmtExcel => 'Скачать Excel';

  @override
  String get stmtShared => 'Файл Excel готов';

  @override
  String get stmtTotal => 'Итого';

  @override
  String get stmtCount => 'Операций';

  @override
  String get stmtCashTotal => 'Наличные';

  @override
  String get stmtCardTotal => 'Карта';

  @override
  String get stmtQrTotal => 'QR';

  @override
  String get stmtNoMethod => 'Способ не указан';

  @override
  String get stmtSalesTotal => 'Продажи';

  @override
  String get stmtExpensesTotal => 'Расходы';

  @override
  String get stmtSalariesTotal => 'Зарплаты';

  @override
  String get stmtProfitTotal => 'Прибыль';

  @override
  String get stmtDue => 'Начислено';

  @override
  String get stmtPaid => 'Выплачено';

  @override
  String get stmtRemaining => 'Долг';

  @override
  String get colDate => 'Дата';

  @override
  String get colStore => 'Магазин';

  @override
  String get colMethod => 'Способ оплаты';

  @override
  String get colCash => 'Наличные';

  @override
  String get colCard => 'Карта / QR';

  @override
  String get colAmount => 'Сумма, TJS';

  @override
  String get colReceipt => 'Чек';

  @override
  String get colDescription => 'Описание';

  @override
  String get colCategory => 'Категория';

  @override
  String get colEmployee => 'Сотрудник';

  @override
  String get colForMonth => 'За месяц';

  @override
  String get colNote => 'Комментарий';

  @override
  String get colWhat => 'Что';

  @override
  String get colWho => 'Магазин / сотрудник';

  @override
  String get colUser => 'Кто внёс';

  @override
  String get colUnpaidMonths => 'Месяцев не выплачено';

  @override
  String get colItem => 'Статья';

  @override
  String get colPlace => 'Место';

  @override
  String get colShare => 'Доля, %';

  @override
  String get colSalesCount => 'Продаж';

  @override
  String get moreStatementsHint =>
      'Выписки в Excel: продажи, наличные, карта, расходы…';

  @override
  String get securityTitle => 'Безопасность';

  @override
  String get lockFaceId => 'Вход по Face ID';

  @override
  String get lockFingerprint => 'Вход по отпечатку пальца';

  @override
  String get lockBiometric => 'Вход по биометрии';

  @override
  String get lockHint => 'Спрашивать при каждом открытии приложения';

  @override
  String get lockUnavailable =>
      'На этом телефоне не настроены Face ID или отпечаток';

  @override
  String get lockReasonEnable =>
      'Подтвердите, чтобы включить вход по биометрии';

  @override
  String get lockReasonOpen => 'Откройте OFAR';

  @override
  String get lockTitle => 'OFAR заблокирован';

  @override
  String get lockMessage =>
      'Подтвердите, что это вы, чтобы увидеть свой бизнес.';

  @override
  String get lockUnlock => 'Разблокировать';

  @override
  String get lockOn => 'Вход по биометрии включён';

  @override
  String get lockOff => 'Вход по биометрии выключен';

  @override
  String get lockNotConfirmed =>
      'Не подтверждено — вход по биометрии не включён';

  @override
  String get navCurrencies => 'Валюты';

  @override
  String get currenciesSoon => 'Скоро здесь что-то появится.';

  @override
  String fxUpdated(String time) {
    return 'Обновлено: $time';
  }

  @override
  String get fxRefresh => 'Обновить';

  @override
  String get fxConverter => 'Конвертер';

  @override
  String get fxAmount => 'СУММА';

  @override
  String get fxSwap => 'Поменять местами';

  @override
  String get fxFrom => 'Из валюты';

  @override
  String get fxTo => 'В валюту';

  @override
  String get fxCrypto => 'Крипто';

  @override
  String get fxCryptoNote =>
      'Только курс — купить, продать или обменять здесь нельзя';

  @override
  String get fxAll => 'Все';

  @override
  String get fxAllCrypto => 'Криптовалюты';

  @override
  String get fxSearchCoin => 'Название или тикер монеты';

  @override
  String get fxSources =>
      'Курсы: open.er-api.com (раз в сутки), крипто: CoinGecko (в реальном времени).';

  @override
  String get fxCryptoUnavailable => 'Курсы криптовалют сейчас недоступны.';

  @override
  String fxLive(String time) {
    return 'В реальном времени · $time';
  }

  @override
  String get navDebts => 'Долги';

  @override
  String get debtsTitle => 'Долги и кредиты';

  @override
  String get debtsOverview => 'Обзор';

  @override
  String get debtsOwedToMe => 'Мне должны';

  @override
  String get debtsIOwe => 'Я должен';

  @override
  String get debtsToPeople => 'Долги людям';

  @override
  String get debtsLoans => 'Кредиты и рассрочки';

  @override
  String debtsPeople(int count) {
    return '$count чел.';
  }

  @override
  String debtsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count долга',
      many: '$count долгов',
      few: '$count долга',
      one: '$count долг',
    );
    return '$_temp0';
  }

  @override
  String get debtsEmptyOwedTitle => 'Вам должны деньги';

  @override
  String get debtsEmptyOwedMessage => 'Добавьте человека, который вам должен';

  @override
  String get debtsEmptyIOweTitle => 'Вы должны деньги';

  @override
  String get debtsEmptyIOweMessage => 'Добавьте человека, которому вы должны';

  @override
  String get debtsAdd => 'Добавить долг';

  @override
  String get debtsActiveLoans => 'Активные кредиты';

  @override
  String get debtsAddLoan => 'Добавить кредит';

  @override
  String get debtsNoLoans => 'Нет активных кредитов и рассрочек';

  @override
  String get debtsClosed => 'Погашенные';

  @override
  String get debtsLocalNote =>
      'Хранится только на этом телефоне: на сервере долгов пока нет.';

  @override
  String debtLeft(String amount) {
    return 'Осталось $amount';
  }

  @override
  String debtDue(String date) {
    return 'До $date';
  }

  @override
  String debtOverdue(String date) {
    return 'Просрочен с $date';
  }

  @override
  String get debtNewOwed => 'Мне должны';

  @override
  String get debtNewIOwe => 'Я должен';

  @override
  String get debtNewLoan => 'Новый кредит';

  @override
  String get debtEditTitle => 'Изменить';

  @override
  String get debtWho => 'Кто';

  @override
  String get debtWhoHint => 'Имя';

  @override
  String get debtBank => 'Банк или магазин';

  @override
  String get debtLoanType => 'Тип';

  @override
  String get debtCredit => 'Кредит';

  @override
  String get debtInstallment => 'Рассрочка';

  @override
  String get debtAmountTotal => 'Всего вернуть';

  @override
  String get debtMonthly => 'Платёж в месяц';

  @override
  String get debtDueDate => 'Вернуть до';

  @override
  String get debtNoDueDate => 'Без срока';

  @override
  String get debtSaved => 'Сохранено';

  @override
  String get debtRepay => 'Записать погашение';

  @override
  String get debtRepayAll => 'Погашен полностью';

  @override
  String get debtRepaid => 'Погашение записано';

  @override
  String get debtPayments => 'Погашения';

  @override
  String get debtNoPayments => 'Погашений пока нет.';

  @override
  String debtPaidOf(String paid, String total) {
    return 'Погашено $paid из $total';
  }

  @override
  String get debtDeleteTitle => 'Удалить?';

  @override
  String get debtDeleteMessage =>
      'Он и его погашения будут удалены с этого телефона.';

  @override
  String get debtDeleted => 'Удалено';

  @override
  String get debtClosedBadge => 'Погашен';

  @override
  String get actionSalesList => 'Продажи';

  @override
  String get pfExpense => 'Расход';

  @override
  String get pfIncome => 'Доход';

  @override
  String get pfTransfer => 'Перевод';

  @override
  String get pfNewExpense => 'Новый расход';

  @override
  String get pfNewIncome => 'Новый доход';

  @override
  String get pfNewTransfer => 'Перевод между счетами';

  @override
  String get pfEditOperation => 'Операция';

  @override
  String get pfAccount => 'Счёт';

  @override
  String get pfFromAccount => 'Со счёта';

  @override
  String get pfToAccount => 'На счёт';

  @override
  String get pfSameAccount => 'Выберите другой счёт';

  @override
  String get pfSaved => 'Сохранено';

  @override
  String get pfDeleted => 'Удалено';

  @override
  String get pfDeleteTitle => 'Удалить операцию?';

  @override
  String get pfDeleteMessage => 'Остаток на счёте пересчитается.';

  @override
  String get pfOperations => 'Операции';

  @override
  String get pfNoOperations =>
      'Операций пока нет. Нажмите «+», чтобы записать расход или доход.';

  @override
  String get pfAccounts => 'Счета';

  @override
  String get pfAccountsHint => 'Наличные, карты и их остатки';

  @override
  String get pfNewAccount => 'Новый счёт';

  @override
  String get pfAccountName => 'Название';

  @override
  String get pfAccountNameHint => 'Карта Алиф, наличные…';

  @override
  String get pfAccountKind => 'Тип';

  @override
  String get pfOpeningBalance => 'Сейчас на счёте';

  @override
  String get pfAccountUsed => 'По счёту есть операции — сначала удалите их.';

  @override
  String get pfAccountDeleteTitle => 'Удалить счёт?';

  @override
  String get pfKindCash => 'Наличные';

  @override
  String get pfKindCard => 'Карта';

  @override
  String get pfKindBank => 'Банковский счёт';

  @override
  String get pfKindSavings => 'Накопления';

  @override
  String get pfKindOther => 'Другое';

  @override
  String get pfTotalBalance => 'Мои деньги';

  @override
  String get pfRecurring => 'Регулярные платежи';

  @override
  String get pfRecurringHint => 'Аренда, интернет, подписки';

  @override
  String get pfNewRecurring => 'Новый регулярный платёж';

  @override
  String get pfRecurringName => 'За что';

  @override
  String get pfRecurringNameHint => 'Интернет, аренда…';

  @override
  String get pfNextDate => 'Следующий платёж';

  @override
  String get pfEvery => 'Как часто';

  @override
  String get pfEveryMonth => 'Каждый месяц';

  @override
  String get pfEveryQuarter => 'Раз в 3 месяца';

  @override
  String get pfEveryYear => 'Раз в год';

  @override
  String get pfAnyAccount => 'Выбрать при оплате';

  @override
  String get pfPay => 'Оплатить';

  @override
  String get pfPaid => 'Оплачено — записано в расходы';

  @override
  String get pfNoRecurring => 'Регулярных платежей пока нет.';

  @override
  String pfDue(String date) {
    return '$date';
  }

  @override
  String get pfDueToday => 'Сегодня';

  @override
  String pfOverdue(String date) {
    return 'Просрочен · $date';
  }

  @override
  String get pfUpcoming => 'Ближайшие платежи';

  @override
  String get pfMonthIncome => 'Доходы';

  @override
  String get pfMonthExpense => 'Расходы';

  @override
  String get pfByCategory => 'Расходы по категориям';

  @override
  String get pfNoExpensesMonth => 'В этом месяце расходов нет.';

  @override
  String get pfRecent => 'Последние операции';

  @override
  String get pfMyFinances => 'Мои финансы';

  @override
  String get pfLocalNote => 'Личные финансы хранятся только на этом телефоне.';

  @override
  String get pfCatFood => 'Продукты';

  @override
  String get pfCatCafe => 'Кафе и рестораны';

  @override
  String get pfCatTransport => 'Транспорт';

  @override
  String get pfCatHome => 'Жильё и аренда';

  @override
  String get pfCatUtilities => 'Коммунальные';

  @override
  String get pfCatPhone => 'Связь и интернет';

  @override
  String get pfCatHealth => 'Здоровье';

  @override
  String get pfCatClothes => 'Одежда';

  @override
  String get pfCatEducation => 'Образование';

  @override
  String get pfCatFun => 'Развлечения';

  @override
  String get pfCatGifts => 'Подарки';

  @override
  String get pfCatFamily => 'Семья';

  @override
  String get pfCatOtherExpense => 'Другое';

  @override
  String get pfCatSalary => 'Зарплата';

  @override
  String get pfCatBusiness => 'Бизнес';

  @override
  String get pfCatSideJob => 'Подработка';

  @override
  String get pfCatGiftIn => 'Подарок';

  @override
  String get pfCatRefund => 'Возврат';

  @override
  String get pfCatOtherIncome => 'Другой доход';

  @override
  String get phMonthIncome => 'Доходы за месяц';

  @override
  String get phMonthExpense => 'Расходы за месяц';

  @override
  String get phMyBusiness => 'Мой бизнес';

  @override
  String phBusinessToday(String amount, String profit) {
    return 'Продажи сегодня $amount · прибыль за месяц $profit';
  }

  @override
  String get phStartBusinessTitle => 'Есть магазин?';

  @override
  String get phStartBusinessMessage =>
      'Добавьте его — появятся продажи, сотрудники, зарплаты и его расходы.';

  @override
  String get phAddStore => 'Добавить магазин';

  @override
  String get phAddAccount => 'Добавить счёт';

  @override
  String get phOpen => 'Открыть';

  @override
  String get actionStoreExpense => 'Расход магазина';

  @override
  String get quickPersonal => 'Личное';

  @override
  String get quickBusiness => 'Бизнес';

  @override
  String get morePersonal => 'Мои деньги';

  @override
  String get moreOperationsHint => 'Все доходы, расходы и переводы';

  @override
  String get assistantSuggestSpending => 'На что я трачу больше всего?';

  @override
  String get assistantSuggestMonth => 'Сколько я потратил в этом месяце?';

  @override
  String get moreReportsAllHint =>
      'Прибыль, выписки в Excel, история изменений';

  @override
  String get moreCurrenciesHint => 'Курсы, конвертер, крипта';

  @override
  String get reportsProfitHint => 'Сравнение магазинов, зарплаты за год';

  @override
  String get reportsHistoryHint => 'Все изменения: продажи, расходы, зарплаты';

  @override
  String get navOperations => 'Операции';

  @override
  String get qeTitle => 'Быстрая запись';

  @override
  String get qeHint => 'Такси 50, обед 35 картой…';

  @override
  String get qeHelp =>
      'Скажите или напишите, на что и сколько: «такси 50», «получил зарплату 3000 на карту».';

  @override
  String get qeSpeak => 'Сказать';

  @override
  String get qeListening => 'Слушаю…';

  @override
  String get qeNoAmount =>
      'Не нашёл сумму — добавьте число, например «такси 50».';

  @override
  String get qeWrite => 'Записать';

  @override
  String get qeEdit => 'Изменить';

  @override
  String get qeNoCategory => 'Категория: выберите в «Изменить»';

  @override
  String get qeMicFailed => 'Микрофон не включился — напишите текстом.';

  @override
  String get qeButton => 'Скажите или напишите: «такси 50»';

  @override
  String get remTitle => 'ИИ-бухгалтер';

  @override
  String remPaymentTomorrow(String name, String amount) {
    return 'Завтра платёж: $name, $amount';
  }

  @override
  String remPaymentToday(String name, String amount) {
    return 'Сегодня платёж: $name, $amount. Отметьте «Оплатить» в приложении.';
  }

  @override
  String remDebtTomorrow(String name, String amount) {
    return 'Завтра срок долга: $name, $amount';
  }

  @override
  String remDebtToday(String name, String amount) {
    return 'Сегодня срок долга: $name, $amount';
  }

  @override
  String get pfCurrency => 'Валюта';

  @override
  String get pfCurrencyLocked => 'По счёту есть операции — валюту не изменить.';

  @override
  String get pfReceived => 'Пришло на счёт';

  @override
  String get pfInTjsNote =>
      'Валютные счета посчитаны в сомони по сегодняшнему курсу.';

  @override
  String get pfRatesMissing =>
      'Курсы ещё не загрузились — валютные счета посчитаны без пересчёта.';

  @override
  String get goalTitle => 'Цели накоплений';

  @override
  String get goalHint => 'Машина, квартира, поездка…';

  @override
  String get goalNew => 'Новая цель';

  @override
  String get goalName => 'На что копим';

  @override
  String get goalNameHint => 'На машину';

  @override
  String get goalTarget => 'Сколько нужно';

  @override
  String get goalDeadline => 'К какому сроку';

  @override
  String get goalNoDeadline => 'Без срока';

  @override
  String get goalTopUp => 'Пополнить';

  @override
  String goalSaved(String saved, String target) {
    return '$saved из $target';
  }

  @override
  String get goalReached => 'Цель достигнута!';

  @override
  String goalLeft(String amount, String date) {
    return 'Осталось $amount · до $date';
  }

  @override
  String goalLeftNoDate(String amount) {
    return 'Осталось $amount';
  }

  @override
  String goalPerMonth(String amount) {
    return '≈ $amount в месяц';
  }

  @override
  String get goalEmpty =>
      'Целей пока нет. Деньги каждой цели лежат на своём счёте-копилке.';

  @override
  String get goalDeleteTitle => 'Удалить цель?';

  @override
  String get goalDeleteMessage => 'Счёт и деньги на нём останутся.';

  @override
  String get opsSearch => 'Поиск: заметка, категория, счёт';

  @override
  String get opsClear => 'Очистить';

  @override
  String get opsAll => 'Все';

  @override
  String get opsExpenses => 'Расходы';

  @override
  String get opsIncome => 'Доходы';

  @override
  String get opsTransfers => 'Переводы';

  @override
  String get opsAllAccounts => 'Все счета';

  @override
  String get opsAllCategories => 'Все категории';

  @override
  String get opsReset => 'Сбросить фильтры';

  @override
  String opsFound(int count, String income, String expense) {
    return 'Найдено: $count · доходы $income · расходы $expense';
  }

  @override
  String get opsNothing => 'Ничего не найдено.';

  @override
  String get opsExcel => 'В Excel';

  @override
  String get opsExcelTitle => 'Мои операции';

  @override
  String get opsColType => 'Тип';

  @override
  String get opsColTo => 'На счёт';

  @override
  String get opsTotalIncome => 'Доходы, TJS';

  @override
  String get opsTotalExpense => 'Расходы, TJS';

  @override
  String get bkTitle => 'Резервная копия';

  @override
  String get bkHint => 'Сохранить в файл и восстановить';

  @override
  String get bkAbout =>
      'Личные финансы и долги хранятся только на этом телефоне. Время от времени сохраняйте копию в файл (в «Файлы», iCloud или «Избранное» Telegram), чтобы не потерять их вместе с телефоном.';

  @override
  String get bkSave => 'Сохранить копию в файл';

  @override
  String get bkRestore => 'Восстановить из файла';

  @override
  String get bkBadFile => 'Этот файл — не резервная копия этого приложения.';

  @override
  String get bkConfirmTitle => 'Восстановить копию?';

  @override
  String bkConfirmMessage(
    String date,
    int accounts,
    int operations,
    int debts,
  ) {
    return 'От $date: счетов $accounts, операций $operations, долгов $debts. То, что сейчас на телефоне, будет заменено.';
  }

  @override
  String get bkRestoreAction => 'Восстановить';

  @override
  String get bkRestored => 'Восстановлено';

  @override
  String get actionFromStore => 'Взял из магазина';

  @override
  String get fromStoreNote => 'Из кассы магазина';

  @override
  String get pfCatDebtOut => 'Дал в долг';

  @override
  String get pfCatDebtPay => 'Погашение долга';

  @override
  String get pfCatDebtIn => 'Взял в долг';

  @override
  String get pfCatDebtBack => 'Вернули долг';

  @override
  String get debtAccount => 'Записать в счёт';

  @override
  String get debtNoAccount => 'Не записывать';

  @override
  String get sessionOfflineTitle => 'Нет связи с сервером';

  @override
  String get sessionOfflineMessage =>
      'Вы по-прежнему в аккаунте. Проверьте интернет и попробуйте снова.';

  @override
  String get sessionTooOld => 'Для безопасности войдите снова (раз в неделю).';

  @override
  String get errActionNotFound => 'Это предложение не найдено.';

  @override
  String get errConversationNotFound => 'Этот чат удалён.';

  @override
  String get errActionAlreadyHandled =>
      'Это предложение уже подтверждено или отменено.';

  @override
  String get errActionExpired =>
      'Предложение устарело. Спросите ассистента ещё раз.';

  @override
  String get actConfirm => 'Подтвердить';

  @override
  String get actConfirmAgain => 'Подтвердить снова';

  @override
  String get actCancel => 'Отмена';

  @override
  String get actDone => 'Готово';

  @override
  String get actCancelled => 'Отменено · спросите ассистента снова';

  @override
  String get actExpired => 'Устарело · спросите ассистента снова';

  @override
  String actFailed(String reason) {
    return 'Не выполнено: $reason';
  }

  @override
  String get actSureTitle => 'Вы уверены?';

  @override
  String actSureMessage(String summary) {
    return '$summary Отменить это из чата не получится.';
  }

  @override
  String get chatRename => 'Переименовать';

  @override
  String get chatRenameTitle => 'Название чата';

  @override
  String get chatDelete => 'Удалить';

  @override
  String get chatDeleteTitle => 'Удалить чат?';

  @override
  String get chatDeleteMessage => 'Он исчезнет на всех устройствах.';

  @override
  String get chatHistoryServerEmpty =>
      'Здесь будут ваши чаты с ассистентом — на всех устройствах, где вы вошли.';

  @override
  String chatMessages(int count) {
    return 'Сообщений: $count';
  }

  @override
  String get chatMore => 'Показать ещё';

  @override
  String chatWaitSeconds(int seconds) {
    return 'Слишком много вопросов. Следующий — через $seconds с.';
  }

  @override
  String get chatOptions => 'Действия с чатом';
}
