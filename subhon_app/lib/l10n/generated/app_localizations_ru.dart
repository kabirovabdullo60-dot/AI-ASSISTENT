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
  String get authRegisterTitle => 'Регистрация';

  @override
  String get authRegisterSubtitle => 'Аккаунт и ваш бизнес — за пару минут';

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
}
