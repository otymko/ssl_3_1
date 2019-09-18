﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Отправляет SMS через МТС.
//
// Параметры:
//  НомераПолучателей - Массив - номера получателей в формате +7ХХХХХХХХХХ (строкой);
//  Текст             - Строка - текст сообщения, длиной не более 1000 символов;
//  ИмяОтправителя 	  - Строка - имя отправителя, которое будет отображаться вместо номера входящего SMS;
//  Логин             - Строка - логин пользователя услуги отправки sms;
//  Пароль            - Строка - пароль пользователя услуги отправки sms.
//
// Возвращаемое значение:
//  Структура: ОтправленныеСообщения - Массив структур: НомерОтправителя.
//                                                  ИдентификаторСообщения.
//             ОписаниеОшибки    - Строка - пользовательское представление ошибки, если пустая строка,
//                                          то ошибки нет.
Функция ОтправитьSMS(НомераПолучателей, Текст, ИмяОтправителя, Логин, Знач Пароль) Экспорт
	
	Результат = Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Новый Массив, "");
	
	Получатели = Новый Массив;
	Для Каждого Элемент Из НомераПолучателей Цикл
		НомерПолучателя = ФорматироватьНомер(Элемент);
		Если Получатели.Найти(НомерПолучателя) = Неопределено Тогда
			Получатели.Добавить(НомерПолучателя);
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("msids", Получатели);
	ПараметрыЗапроса.Вставить("message", Текст);
	ПараметрыЗапроса.Вставить("naming", ИмяОтправителя);
	
	Если ЗначениеЗаполнено(Логин) Тогда
		ПараметрыЗапроса.Вставить("login", Логин);
		ПараметрыЗапроса.Вставить("password", ОбщегоНазначения.КонтрольнаяСуммаСтрокой(Пароль));
	КонецЕсли;
	
	РезультатЗапроса = ВыполнитьЗапрос("SendMessages", ПараметрыЗапроса);
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		Результат.ОписаниеОшибки = ОписаниеОшибкиПоКоду(РезультатЗапроса.ОтветСервера);
		Возврат Результат;
	КонецЕсли;
	
	ДокументDOM = ДокументDOM(РезультатЗапроса.ОтветСервера);
	Разыменователь = ДокументDOM.СоздатьРазыменовательПИ();
	
	ОтправленныеСообщения = ДокументDOM.ВычислитьВыражениеXPath("/xmlns:ArrayOfSendMessageIDs/xmlns:SendMessageIDs",
		ДокументDOM, Разыменователь);
	
	Сообщение = ОтправленныеСообщения.ПолучитьСледующий();
	Пока Сообщение <> Неопределено Цикл
		НомерПолучателя = ДокументDOM.ВычислитьВыражениеXPath("xmlns:Msid", Сообщение, Разыменователь).ПолучитьСледующий().ТекстовоеСодержимое;
		ИдентификаторСообщения = ДокументDOM.ВычислитьВыражениеXPath("xmlns:MessageID", Сообщение, Разыменователь).ПолучитьСледующий().ТекстовоеСодержимое;
		
		Результат.ОтправленныеСообщения.Добавить(Новый Структура("НомерПолучателя,ИдентификаторСообщения",
			"+" +  НомерПолучателя, Формат(ИдентификаторСообщения, "ЧГ=")));
		
		Сообщение = ОтправленныеСообщения.ПолучитьСледующий();
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Возвращает текстовое представление статуса доставки сообщения.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный sms при отправке;
//  НастройкиОтправкиSMS   - Структура - см. ОтправкаSMSПовтИсп.НастройкиОтправкиSMS;
//
// Возвращаемое значение:
//  Строка - статус доставки. См. описание функции ОтправкаSMS.СтатусДоставки.
Функция СтатусДоставки(ИдентификаторСообщения, НастройкиОтправкиSMS) Экспорт
	
	Результат = "Ошибка";
	
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("messageID", ИдентификаторСообщения);
	
	Если ЗначениеЗаполнено(НастройкиОтправкиSMS.Логин) Тогда
		ПараметрыЗапроса.Вставить("login", НастройкиОтправкиSMS.Логин);
		ПараметрыЗапроса.Вставить("password", ОбщегоНазначения.КонтрольнаяСуммаСтрокой(НастройкиОтправкиSMS.Пароль));
	КонецЕсли;
	
	РезультатЗапроса = ВыполнитьЗапрос("GetMessageStatus", ПараметрыЗапроса);
	Если Не РезультатЗапроса.ЗапросВыполнен Тогда
		Возврат Результат;
	КонецЕсли;
	
	ДокументDOM = ДокументDOM(РезультатЗапроса.ОтветСервера);
	Разыменователь = ДокументDOM.СоздатьРазыменовательПИ();
	
	НайденныйЭлемент = ДокументDOM.ВычислитьВыражениеXPath("/xmlns:ArrayOfDeliveryInfo/xmlns:DeliveryInfo/xmlns:DeliveryStatus",
		ДокументDOM, Разыменователь).ПолучитьСледующий();
		
	Если НайденныйЭлемент = Неопределено Тогда
		Возврат Результат;
	КонецЕсли;
	
	Результат = СтатусДоставкиSMS(НайденныйЭлемент.ТекстовоеСодержимое);
	Возврат Результат;
	
КонецФункции

Функция ФорматироватьНомер(Номер)
	Результат = "";
	ДопустимыеСимволы = "1234567890";
	Для Позиция = 1 По СтрДлина(Номер) Цикл
		Символ = Сред(Номер,Позиция,1);
		Если СтрНайти(ДопустимыеСимволы, Символ) > 0 Тогда
			Результат = Результат + Символ;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция СтатусДоставкиSMS(СтатусСтрокой)
	СоответствиеСтатусов = Новый Соответствие;
	СоответствиеСтатусов.Вставить("Pending", "НеОтправлялось");
	СоответствиеСтатусов.Вставить("Sending", "Отправляется");
	СоответствиеСтатусов.Вставить("Sent", "Отправлено");
	СоответствиеСтатусов.Вставить("NotSent", "НеОтправлено");
	СоответствиеСтатусов.Вставить("Delivered", "Доставлено");
	СоответствиеСтатусов.Вставить("NotDelivered", "НеДоставлено");
	СоответствиеСтатусов.Вставить("TimedOut", "НеДоставлено");
	
	Результат = СоответствиеСтатусов[СтатусСтрокой];
	Возврат ?(Результат = Неопределено, "Ошибка", Результат);
КонецФункции

Функция ОписанияОшибок()
	ОписанияОшибок = Новый Соответствие;
	ОписанияОшибок.Вставить("SYSTEM_FAILURE", НСтр("ru = 'Временная проблема на стороне МТС.'"));
	ОписанияОшибок.Вставить("TOO_MANY_PARAMETERS", НСтр("ru = 'Превышено максимальное число параметров.'"));
	ОписанияОшибок.Вставить("INCORRECT_PASSWORD", НСтр("ru = 'Предоставленные логин/пароль не верны.'"));
	ОписанияОшибок.Вставить("MSID_FORMAT_ERROR", НСтр("ru = 'Формат номера неверный.'"));
	ОписанияОшибок.Вставить("MESSAGE_FORMAT_ERROR", НСтр("ru = 'Ошибка в формате сообщения.'"));
	ОписанияОшибок.Вставить("WRONG_ID", НСтр("ru = 'Передан неверный идентификатор.'"));
	ОписанияОшибок.Вставить("MESSAGE_HANDLING_ERROR", НСтр("ru = 'Ошибка в обработке сообщения'"));
	ОписанияОшибок.Вставить("NO_SUCH_SUBSCRIBER", НСтр("ru = 'Данный абонент не зарегистрирован в Услуге в учетной записи клиента (или еще не дал подтверждение).'"));
	ОписанияОшибок.Вставить("TEST_LIMIT_EXCEEDED", НСтр("ru = 'Превышен лимит по количеству сообщений в тестовой эксплуатации.'"));
	ОписанияОшибок.Вставить("TRUSTED_LIMIT_EXCEEDED", НСтр("ru = 'Превышен лимит по количеству сообщений для абонентов, которые были добавлены без подтверждения.'"));
	ОписанияОшибок.Вставить("IP_NOT_ALLOWED", НСтр("ru = 'Доступ к сервису с данного IP невозможен (список допустимых IP-адресов можно указывается при подключении услуги).'"));
	ОписанияОшибок.Вставить("MAX_LENGTH_EXCEEDED", НСтр("ru = 'Превышена максимальная длина сообщения (1000 символов).'"));
	ОписанияОшибок.Вставить("OPERATION_NOT_ALLOWED", НСтр("ru = 'Пользователь услуги не имеет прав на выполнение данной операции.'"));
	ОписанияОшибок.Вставить("EMPTY_MESSAGE_NOT_ALLOWED", НСтр("ru = 'Отправка пустых сообщений не допускается.'"));
	ОписанияОшибок.Вставить("ACCOUNT_IS_BLOCKED", НСтр("ru = 'Учетная запись заблокирована, отправка сообщений не возможна.'"));
	ОписанияОшибок.Вставить("OBJECT_ALREADY_EXISTS", НСтр("ru = 'Список рассылки с указанным названием уже существует в рамках компании.'"));
	ОписанияОшибок.Вставить("MSID_IS_IN_BLACKLIST", НСтр("ru = 'Номер абонента находится в черном списке, отправка сообщений запрещена.'"));
	ОписанияОшибок.Вставить("MSIDS_ARE_IN_BLACKLIST", НСтр("ru = 'Все указанные номера абонентов находятся в черном списке, отправка сообщений запрещена.'"));
	ОписанияОшибок.Вставить("TIME_IS_IN_THE_PAST", НСтр("ru = 'Переданное время в прошлом.'"));
	
	Возврат ОписанияОшибок;
КонецФункции

Функция ОписаниеОшибкиПоКоду(Знач КодОшибки)
	КодОшибки = СокрЛП(КодОшибки);
	ОписанияОшибок = ОписанияОшибок();
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = НСтр("ru = 'Отказ выполнения операции.'") + Символы.ПС
			+ КодОшибки;
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

// Возвращает список разрешений для отправки SMS с использованием всех доступных провайдеров.
//
// Возвращаемое значение:
//  Массив - .
//
Функция Разрешения() Экспорт
	Протокол = "HTTPS";
	Адрес = "https://mcommunicator.ru";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Отправка SMS через МТС.'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(
		МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание));
	
	Возврат Разрешения;
КонецФункции

Функция ВыполнитьЗапрос(ИмяМетода, ПараметрыЗапроса)
	
	Результат = Новый Структура;
	Результат.Вставить("ЗапросВыполнен", Ложь);
	Результат.Вставить("ОтветСервера", "");
	
	HTTPЗапрос = ОтправкаSMS.ПодготовитьHTTPЗапрос("/m2m/m2m_api.asmx/" + ИмяМетода, ПараметрыЗапроса, Ложь);
	HTTPОтвет = Неопределено;
	
	Попытка
		Соединение = Новый HTTPСоединение("api.mcommunicator.ru", , , , ПолучениеФайловИзИнтернета.ПолучитьПрокси("https"),
			60, ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение());
			
		HTTPОтвет = Соединение.Получить(HTTPЗапрос);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
	Если HTTPОтвет <> Неопределено Тогда
		Если HTTPОтвет.КодСостояния <> 200 Тогда
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Запрос ""%1"" не выполнен. Код состояния: %2.'"), ИмяМетода, HTTPОтвет.КодСостояния) + Символы.ПС
				+ HTTPОтвет.ПолучитьТелоКакСтроку();
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);
		КонецЕсли;
		
		Результат.ЗапросВыполнен = HTTPОтвет.КодСостояния = 200;
		Результат.ОтветСервера = HTTPОтвет.ПолучитьТелоКакСтроку();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ПриОпределенииНастроек(Настройки) Экспорт
	
	Настройки.АдресОписанияУслугиВИнтернете = "http://www.mtscommunicator.ru/service/";
	Настройки.ПриОпределенииСпособовАвторизации = Истина;
	
КонецПроцедуры

Процедура ПриОпределенииСпособовАвторизации(СпособыАвторизации) Экспорт
	
	ПоляАвторизации = Новый СписокЗначений;
	ПоляАвторизации.Добавить("Пароль", НСтр("ru = 'Ключ API'"));
	
	СпособыАвторизации.Вставить("ПоКлючу", ПоляАвторизации);
	
КонецПроцедуры

Функция ДокументDOM(Строка)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.УстановитьСтроку(Строка);
	ПостроительDOM = Новый ПостроительDOM;
	ДокументDOM = ПостроительDOM.Прочитать(ЧтениеXML);
	ЧтениеXML.Закрыть();
	
	Возврат ДокументDOM;
	
КонецФункции

#КонецОбласти
