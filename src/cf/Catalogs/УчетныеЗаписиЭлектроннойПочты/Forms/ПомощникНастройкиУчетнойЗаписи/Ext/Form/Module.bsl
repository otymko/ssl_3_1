﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.КнопкаПерейтиКНастройкам.Видимость = Ложь;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
		МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
		ИспользуютсяПрофилиБезопасности = МодульРаботаВБезопасномРежиме.ИспользуютсяПрофилиБезопасности();
	Иначе
		ИспользуютсяПрофилиБезопасности = Ложь;
	КонецЕсли;
	
	Элементы.СпособНастройки.Видимость = Не ИспользуютсяПрофилиБезопасности;
	Если ИспользуютсяПрофилиБезопасности Тогда
		СпособНастройки = "Вручную";
	Иначе
		СпособНастройки = "Автоматически";
	КонецЕсли;
	
	ДоступноПолучениеПисем = РаботаСПочтовымиСообщениямиСлужебный.НастройкиПодсистемы().ДоступноПолучениеПисем;
	КонтекстныйРежим = Параметры.КонтекстныйРежим;
	Элементы.ИспользоватьУчетнуюЗапись.Видимость = Не КонтекстныйРежим И ДоступноПолучениеПисем;
	Элементы.Протокол.Доступность = ДоступноПолучениеПисем;
	Элементы.ОставлятьПисьмаНаСервере.Видимость = ДоступноПолучениеПисем;
	
	Элементы.НастройкаУчетнойЗаписиЗаголовок.Заголовок = ?(КонтекстныйРежим,
		НСтр("ru = 'Для отправки писем необходимо настроить учетную запись электронной почты'"),
		НСтр("ru = 'Введите параметры учетной записи'"));
		
	Если Не КонтекстныйРежим Тогда
		Заголовок = НСтр("ru = 'Создание учетной записи электронной почты'");
	Иначе
		Заголовок = НСтр("ru = 'Настройка учетной записи электронной почты'");
	КонецЕсли;
	
	ИспользоватьДляПолучения = Не КонтекстныйРежим И ДоступноПолучениеПисем;
	ИспользоватьДляОтправки = Истина;
	Элементы.Страницы.ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи;
	
	КлючСохраненияПоложенияОкна = ?(КонтекстныйРежим, "КонтекстныйРежим", "НеконтекстныйРежим");
	
	Если Параметры.Свойство("Ключ") Тогда
		УчетнаяЗаписьСсылка = Параметры.Ключ;
		ТекстЗапроса =
		"ВЫБРАТЬ
		|	УчетныеЗаписиЭлектроннойПочты.АдресЭлектроннойПочты КАК АдресЭлектроннойПочты,
		|	УчетныеЗаписиЭлектроннойПочты.ИмяПользователя КАК ИмяОтправителяПисем,
		|	УчетныеЗаписиЭлектроннойПочты.Наименование КАК НазваниеУчетнойЗаписи
		|ИЗ
		|	Справочник.УчетныеЗаписиЭлектроннойПочты КАК УчетныеЗаписиЭлектроннойПочты
		|ГДЕ
		|	УчетныеЗаписиЭлектроннойПочты.Ссылка = &Ссылка";
		Запрос = Новый Запрос(ТекстЗапроса);
		Запрос.УстановитьПараметр("Ссылка", Параметры.Ключ);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
		КонецЕсли;
	Иначе
		СсылкаНовойУчетнойЗаписи = Справочники.УчетныеЗаписиЭлектроннойПочты.ПолучитьСсылку();
		
		Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
			МодульУправлениеКонтактнойИнформацией = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформацией");
			КонтактнаяИнформацияОбъекта = МодульУправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(
				Пользователи.ТекущийПользователь(), Перечисления["ТипыКонтактнойИнформации"].АдресЭлектроннойПочты, , Ложь);
			Для Каждого Контакт Из КонтактнаяИнформацияОбъекта Цикл
				Адрес = Контакт.Представление;
				Если Справочники.УчетныеЗаписиЭлектроннойПочты.НайтиПоРеквизиту("АдресЭлектроннойПочты", Адрес).Пустая() Тогда
					АдресЭлектроннойПочты = Адрес;
					ТекущийЭлемент = Элементы.Пароль;
					ИмяОтправителяПисем = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Пользователи.ТекущийПользователь(), "Наименование");
					Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	ЭтоПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь();
	Элементы.ДляКогоУчетнаяЗапись.Видимость = ЭтоПолноправныйПользователь;
	ВидУчетнойЗаписи = ?(ЭтоПолноправныйПользователь, "Общая", "Персональная");
	
	ТребуетсяАвторизацияПриОтправкеПисем = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	НастроитьЭлементыТекущейСтраницы()
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если Не ТребуетсяПодтверждениеЗакрытияФормы Тогда
		Возврат;
	КонецЕсли;
	
	Отказ = Истина;
	Если ЗавершениеРаботы Тогда
		Возврат;
	КонецЕсли;
	
	ПодключитьОбработчикОжидания("ПоказатьВопросПередЗакрытиемФормы", 0.1, Истина);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	ПарольДляОтправкиПисем = ПарольДляПолученияПисем;
КонецПроцедуры

&НаКлиенте
Процедура ОставлятьКопииПисемНаСервереПриИзменении(Элемент)
	ОбновитьДоступностьНастройкиДнейДоУдаления();
КонецПроцедуры

&НаКлиенте
Процедура УдалятьПисьмаССервераПриИзменении(Элемент)
	ОбновитьДоступностьНастройкиДнейДоУдаления();
КонецПроцедуры

&НаКлиенте
Процедура АдресЭлектроннойПочтыПриИзменении(Элемент)
	НастройкиЗаполнены = Ложь;
	ТребуетсяПодтверждениеЗакрытияФормы = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ИмяОтправителяПисемПриИзменении(Элемент)
	ТребуетсяПодтверждениеЗакрытияФормы = Истина;
КонецПроцедуры

&НаКлиенте
Процедура СпособНастройкиПриИзменении(Элемент)
	НастроитьЭлементыТекущейСтраницы();
КонецПроцедуры

&НаКлиенте
Процедура ПротоколПриИзменении(Элемент)
	УстановитьВидимостьЭлементов();
КонецПроцедуры

&НаКлиенте
Процедура ШифрованиеПриОтправкеПочтыПриИзменении(Элемент)
	ИспользоватьЗащищенноеСоединениеДляИсходящейПочты = ШифрованиеПриОтправкеПочты = "SSL";
КонецПроцедуры

&НаКлиенте
Процедура ШифрованиеПриПолученииПочтыПриИзменении(Элемент)
	ИспользоватьЗащищенноеСоединениеДляВходящейПочты = ШифрованиеПриПолученииПочты = "SSL";
КонецПроцедуры

&НаКлиенте
Процедура НужнаПомощьНажатие(Элемент)
	
	РаботаСПочтовымиСообщениямиКлиент.ПерейтиКДокументацииПоВводуУчетнойЗаписиЭлектроннойПочты();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте

Процедура Далее(Команда)
	
	ПерейтиНаСледующуюСтраницу();
	
КонецПроцедуры

&НаКлиенте
Процедура Назад(Команда)
	
	ТекущаяСтраница = Элементы.Страницы.ТекущаяСтраница;
	
	ПредыдущаяСтраница = Неопределено;
	Если ТекущаяСтраница = Элементы.НастройкаСервераИсходящейПочты Тогда
		ПредыдущаяСтраница = Элементы.НастройкаУчетнойЗаписи;
	ИначеЕсли ТекущаяСтраница = Элементы.НастройкаСервераВходящейПочты Тогда
		Если ИспользоватьДляОтправки Тогда
			ПредыдущаяСтраница = Элементы.НастройкаСервераИсходящейПочты;
		Иначе
			ПредыдущаяСтраница = Элементы.НастройкаУчетнойЗаписи;
		КонецЕсли;
	ИначеЕсли ТекущаяСтраница = Элементы.ДополнительныеНастройки Тогда
		Если ИспользоватьДляОтправки Или ИспользоватьДляПолучения Тогда
			ПредыдущаяСтраница = Элементы.НастройкаСервераВходящейПочты;
		ИначеЕсли ИспользоватьДляОтправки Тогда
			ПредыдущаяСтраница = Элементы.НастройкаСервераИсходящейПочты;
		Иначе
			ПредыдущаяСтраница = Элементы.НастройкаУчетнойЗаписи;
		КонецЕсли;
	ИначеЕсли ТекущаяСтраница = Элементы.ПроверкаНастроекУчетнойЗаписи Тогда
		ПредыдущаяСтраница = Элементы.НастройкаУчетнойЗаписи;
	КонецЕсли;
	
	Если ПредыдущаяСтраница <> Неопределено Тогда
		Элементы.Страницы.ТекущаяСтраница = ПредыдущаяСтраница;
	КонецЕсли;
	
	НастроитьЭлементыТекущейСтраницы()
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	Закрыть(Ложь);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПоказатьВопросПередЗакрытиемФормы()
	ТекстВопроса = НСтр("ru = 'Введенные данные не записаны. Закрыть форму?'");
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗакрытиеФормыПодтверждено", ЭтотОбъект);
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить("Закрыть", НСтр("ru = 'Закрыть'"));
	Кнопки.Добавить(КодВозвратаДиалога.Отмена, НСтр("ru = 'Не закрывать'"));
	ПоказатьВопрос(ОписаниеОповещения, ТекстВопроса, Кнопки, , КодВозвратаДиалога.Отмена, НСтр("ru = 'Настройка учетной записи'"));
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеФормыПодтверждено(РезультатВопроса, ДополнительныеПараметры = Неопределено) Экспорт
	
	Если РезультатВопроса = КодВозвратаДиалога.Отмена Тогда
		Возврат;
	КонецЕсли;
	
	ТребуетсяПодтверждениеЗакрытияФормы = Ложь;
	Закрыть(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиНаСледующуюСтраницу()
	
	Отказ = Ложь;
	ТекущаяСтраница = Элементы.Страницы.ТекущаяСтраница;
	
	СледующаяСтраница = Неопределено;
	Если ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи Тогда
		ПроверитьЗаполнениеНаСтраницеНастройкаУчетнойЗаписи(Отказ);
		Если Не Отказ И Не НастройкиЗаполнены Тогда
			ЗаполнитьНастройкиУчетнойЗаписи();
		КонецЕсли;
		Если СпособНастройки = "Автоматически" Или ПроверкаЗавершиласьСОшибками Тогда
			СледующаяСтраница = Элементы.ПроверкаНастроекУчетнойЗаписи;
		Иначе
			Если ИспользоватьДляОтправки Тогда
				СледующаяСтраница = Элементы.НастройкаСервераИсходящейПочты;
			ИначеЕсли ИспользоватьДляПолучения Тогда
				СледующаяСтраница = Элементы.НастройкаСервераВходящейПочты;
			Иначе
				СледующаяСтраница = Элементы.ДополнительныеНастройки;
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли ТекущаяСтраница = Элементы.НастройкаСервераИсходящейПочты Тогда
		СледующаяСтраница = Элементы.НастройкаСервераВходящейПочты;
	ИначеЕсли ТекущаяСтраница = Элементы.НастройкаСервераВходящейПочты Тогда
		СледующаяСтраница = Элементы.ДополнительныеНастройки;
	ИначеЕсли ТекущаяСтраница = Элементы.ДополнительныеНастройки Тогда
		СледующаяСтраница = Элементы.ПроверкаНастроекУчетнойЗаписи;
	ИначеЕсли ТекущаяСтраница = Элементы.ПроверкаНастроекУчетнойЗаписи Тогда
		Если ПроверкаЗавершиласьСОшибками Тогда
			СледующаяСтраница = Элементы.НастройкаУчетнойЗаписи;
		Иначе
			СледующаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена;
		КонецЕсли;
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если СледующаяСтраница = Неопределено Тогда
		Закрыть(Истина);
	Иначе
		Элементы.Страницы.ТекущаяСтраница = СледующаяСтраница;
		НастроитьЭлементыТекущейСтраницы();
	КонецЕсли;
	
	Если Элементы.Страницы.ТекущаяСтраница = Элементы.ПроверкаНастроекУчетнойЗаписи Тогда
		Если СпособНастройки = "Автоматически" Тогда
			ПодключитьОбработчикОжидания("НастроитьПараметрыПодключенияАвтоматически", 0.1, Истина);
		Иначе
			ПодключитьОбработчикОжидания("ВыполнитьПроверкуНастроек", 0.1, Истина);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроверкуНастроек()
	
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ВыполнитьПроверкуНастроекЗапросНаРазрешенияВыполнен", ЭтотОбъект);
	Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
		Запрос = СоздатьЗапросНаИспользованиеВнешнихРесурсов();
		
		МодульРаботаВБезопасномРежимеКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаВБезопасномРежимеКлиент");
		МодульРаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов(
			ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Запрос), ЭтотОбъект, ОповещениеОЗакрытии);
	Иначе
		ВыполнитьОбработкуОповещения(ОповещениеОЗакрытии, КодВозвратаДиалога.ОК);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьПроверкуНастроекЗапросНаРазрешенияВыполнен(РезультатЗапроса, ДополнительныеПараметры) Экспорт
	Если Не РезультатЗапроса = КодВозвратаДиалога.ОК Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьНастройкиУчетнойЗаписи();
	Если ЗначениеЗаполнено(УчетнаяЗаписьСсылка) Тогда 
		ОповеститьОбИзменении(ТипЗнч(УчетнаяЗаписьСсылка));
	КонецЕсли;
	ПерейтиНаСледующуюСтраницу();
КонецПроцедуры

&НаСервере
Функция СоздатьЗапросНаИспользованиеВнешнихРесурсов()
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Возврат МодульРаботаВБезопасномРежиме.ЗапросНаИспользованиеВнешнихРесурсов(
		Разрешения(), СсылкаНовойУчетнойЗаписи);
	
КонецФункции

&НаСервере
Функция Разрешения()
	
	Результат = Новый Массив;
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Если ИспользоватьДляОтправки Тогда
		Результат.Добавить(
			МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(
				"SMTP",
				СерверИсходящейПочты,
				ПортСервераИсходящейПочты,
				НСтр("ru = 'Электронная почта.'")));
	КонецЕсли;
	
	Если ИспользоватьДляПолучения Тогда
		Результат.Добавить(
			МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(
				Протокол,
				СерверВходящейПочты,
				ПортСервераВходящейПочты,
				НСтр("ru = 'Электронная почта.'")));
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции


&НаКлиенте
Процедура ПроверитьЗаполнениеНаСтраницеНастройкаУчетнойЗаписи(Отказ)
	
	ОчиститьСообщения();
	
	Если ПустаяСтрока(АдресЭлектроннойПочты) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Введите адрес электронной почты'"), , "АдресЭлектроннойПочты", , Отказ);
	ИначеЕсли Не ОбщегоНазначенияКлиентСервер.АдресЭлектроннойПочтыСоответствуетТребованиям(АдресЭлектроннойПочты, Истина) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Адрес электронной почты введен неверно'"), , "АдресЭлектроннойПочты", , Отказ);
	КонецЕсли;
	
	Если ПустаяСтрока(ПарольДляПолученияПисем) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Необходимо ввести пароль'"), , "ПарольДляПолученияПисем", , Отказ);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьЭлементыТекущейСтраницы()
	
	ТекущаяСтраница = Элементы.Страницы.ТекущаяСтраница;
	
	// КнопкаДалее
	Если ТекущаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена Тогда
		Если КонтекстныйРежим Тогда
			ЗаголовокКнопкиДалее = НСтр("ru = 'Продолжить'");
		Иначе
			ЗаголовокКнопкиДалее = НСтр("ru = 'Закрыть'");
		КонецЕсли;
	Иначе
		Если ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи
			И ПроверкаЗавершиласьСОшибками Тогда
				ЗаголовокКнопкиДалее = НСтр("ru = 'Повторить'");
		ИначеЕсли ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи
			И СпособНастройки = "Автоматически" Тогда
			Если КонтекстныйРежим Тогда
				ЗаголовокКнопкиДалее = НСтр("ru = 'Настроить'");
			Иначе
				ЗаголовокКнопкиДалее = НСтр("ru = 'Создать'");
			КонецЕсли;
		Иначе
			ЗаголовокКнопкиДалее = НСтр("ru = 'Далее >'");
		КонецЕсли;
	КонецЕсли;
	Элементы.КнопкаДалее.Заголовок = ЗаголовокКнопкиДалее;
	Элементы.КнопкаДалее.Доступность = ТекущаяСтраница <> Элементы.ПроверкаНастроекУчетнойЗаписи;
	Элементы.КнопкаДалее.Видимость = ТекущаяСтраница <> Элементы.ПроверкаНастроекУчетнойЗаписи;
	
	// КнопкаНазад
	Элементы.КнопкаНазад.Видимость = ТекущаяСтраница <> Элементы.НастройкаУчетнойЗаписи
		И ТекущаяСтраница <> Элементы.УчетнаяЗаписьУспешноНастроена
		И ТекущаяСтраница <> Элементы.ПроверкаНастроекУчетнойЗаписи;
	
	// КнопкаОтмена
	Элементы.КнопкаОтмена.Видимость = ТекущаяСтраница <> Элементы.УчетнаяЗаписьУспешноНастроена;
	
	// КнопкаПерейтиКНастройкам
	Элементы.КнопкаПерейтиКНастройкам.Видимость = Не ИспользуютсяПрофилиБезопасности И (ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи
		И ПроверкаЗавершиласьСОшибками Или Не КонтекстныйРежим И ТекущаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена);
		
	Если Не КонтекстныйРежим И ТекущаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена Тогда
		Элементы.КнопкаПерейтиКНастройкам.Заголовок = НСтр("ru = 'Перейти к учетной записи'");
	Иначе
		Элементы.КнопкаПерейтиКНастройкам.Заголовок = НСтр("ru = 'Настроить вручную'");
	КонецЕсли;
	
	Если ТекущаяСтраница = Элементы.НастройкаУчетнойЗаписи Тогда
		Элементы.НеУдалосьПодключитьсяКартинкаИНадпись.Видимость = ПроверкаЗавершиласьСОшибками;
		Элементы.СпособНастройки.Видимость = Не ПроверкаЗавершиласьСОшибками И Не ИспользуютсяПрофилиБезопасности;
	КонецЕсли;
	
	Если ТекущаяСтраница = Элементы.НастройкаСервераВходящейПочты Тогда
		ОбновитьДоступностьНастройкиДнейДоУдаления();
		УстановитьВидимостьЭлементов();
	КонецЕсли;
	
	Если ТекущаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена Тогда
		Элементы.НадписьУчетнаяЗаписьУспешноНастроена.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Настройка параметров учетной записи
				|%1 завершена.'"), АдресЭлектроннойПочты);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДоступностьНастройкиДнейДоУдаления()
	Элементы.УдалятьПисьмаССервера.Доступность = ОставлятьКопииПисемНаСервере;
	Элементы.ПериодХраненияСообщенийНаСервере.Доступность = УдалятьПисьмаССервера;
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимостьЭлементов()
	Элементы.ОставлятьПисьмаНаСервере.Видимость = Протокол = "POP";
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКНастройкам(Команда)
	ТекущаяСтраница = Элементы.Страницы.ТекущаяСтраница;
	Если Не КонтекстныйРежим И ТекущаяСтраница = Элементы.УчетнаяЗаписьУспешноНастроена Тогда
		ПоказатьЗначение(,УчетнаяЗаписьСсылка);
		Закрыть(Истина);
	Иначе
		Если СпособНастройки = "Автоматически" Тогда
			СпособНастройки = "Вручную";
		КонецЕсли;
		Элементы.Страницы.ТекущаяСтраница = Элементы.НастройкаСервераИсходящейПочты;
		НастроитьЭлементыТекущейСтраницы();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьНастройкиУчетнойЗаписи()
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, НастройкиПоУмолчанию(АдресЭлектроннойПочты, ПарольДляПолученияПисем));
	Если ПустаяСтрока(НазваниеУчетнойЗаписи) Тогда
		НазваниеУчетнойЗаписи = АдресЭлектроннойПочты;
	КонецЕсли;

	НастройкиЗаполнены = Истина;
	
	ШифрованиеПриОтправкеПочты = ?(ИспользоватьЗащищенноеСоединениеДляИсходящейПочты, "SSL", "Авто");
	ШифрованиеПриПолученииПочты = ?(ИспользоватьЗащищенноеСоединениеДляВходящейПочты, "SSL", "Авто");
КонецПроцедуры

&НаСервереБезКонтекста
Функция НастройкиПоУмолчанию(АдресЭлектроннойПочты, Пароль)
	
	Позиция = СтрНайти(АдресЭлектроннойПочты, "@");
	ИмяСервераВУчетнойЗаписи = Сред(АдресЭлектроннойПочты, Позиция + 1);
	
	Настройки = Новый Структура;
	
	Настройки.Вставить("ИмяПользователяДляПолученияПисем", АдресЭлектроннойПочты);
	Настройки.Вставить("ИмяПользователяДляОтправкиПисем", АдресЭлектроннойПочты);
	
	Настройки.Вставить("ПарольДляОтправкиПисем", Пароль);
	Настройки.Вставить("ПарольДляПолученияПисем", Пароль);
	
	Настройки.Вставить("Протокол", "IMAP");
	Настройки.Вставить("СерверВходящейПочты", "imap." + ИмяСервераВУчетнойЗаписи);
	Настройки.Вставить("ПортСервераВходящейПочты", 993);
	Настройки.Вставить("ИспользоватьЗащищенноеСоединениеДляВходящейПочты", Истина);
	
	Настройки.Вставить("СерверИсходящейПочты", "smtp." + ИмяСервераВУчетнойЗаписи);
	Настройки.Вставить("ПортСервераИсходящейПочты", 587);
	Настройки.Вставить("ИспользоватьЗащищенноеСоединениеДляИсходящейПочты", Ложь);
	
	Настройки.Вставить("ДлительностьОжиданияСервера", 30);
	Настройки.Вставить("ОставлятьКопииПисемНаСервере", Истина);
	Настройки.Вставить("ПериодХраненияСообщенийНаСервере", 10);
	
	НастройкиIMAPПоУмолчанию = Справочники.УчетныеЗаписиЭлектроннойПочты.ВариантыНастройкиПодключенияКСерверуIMAP(АдресЭлектроннойПочты)[0];
	НастройкиSMTPПоУмолчанию = Справочники.УчетныеЗаписиЭлектроннойПочты.ВариантыНастройкиПодключенияКСерверуSMTP(АдресЭлектроннойПочты)[0];
	
	ЗаполнитьЗначенияСвойств(Настройки, НастройкиIMAPПоУмолчанию);
	ЗаполнитьЗначенияСвойств(Настройки, НастройкиSMTPПоУмолчанию);
	
	Возврат Настройки;
КонецФункции

&НаСервере
Функция ПроверитьПодключениеКСерверуВходящейПочты()
	
	Профиль = ИнтернетПочтовыйПрофиль(Истина);
	ИнтернетПочта = Новый ИнтернетПочта;
	
	ИспользуемыйПротокол = ПротоколИнтернетПочты.POP3;
	Если Протокол = "IMAP" Тогда
		ИспользуемыйПротокол = ПротоколИнтернетПочты.IMAP;
	КонецЕсли;
	
	ТекстОшибки = "";
	Попытка
		ИнтернетПочта.Подключиться(Профиль, ИспользуемыйПротокол);
	Исключение
		ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	ИнтернетПочта.Отключиться();
	
	Возврат ТекстОшибки;
	
КонецФункции

&НаСервере
Функция ПроверитьПодключениеКСерверуИсходящейПочты()
	
	Тема = НСтр("ru = 'Тестовое сообщение 1С:Предприятие'");
	Тело = НСтр("ru = 'Это сообщение отправлено подсистемой электронной почты 1С:Предприятие'");
	
	Письмо = Новый ИнтернетПочтовоеСообщение;
	Письмо.Тема = Тема;
	
	Получатель = Письмо.Получатели.Добавить(АдресЭлектроннойПочты);
	Получатель.ОтображаемоеИмя = ИмяОтправителяПисем;
	
	Письмо.ИмяОтправителя = ИмяОтправителяПисем;
	Письмо.Отправитель.ОтображаемоеИмя = ИмяОтправителяПисем;
	Письмо.Отправитель.Адрес = АдресЭлектроннойПочты;
	
	Текст = Письмо.Тексты.Добавить(Тело);
	Текст.ТипТекста = ТипТекстаПочтовогоСообщения.ПростойТекст;

	Профиль = ИнтернетПочтовыйПрофиль();
	ИнтернетПочта = Новый ИнтернетПочта;
	
	ТекстОшибки = "";
	Попытка
		ИнтернетПочта.Подключиться(Профиль);
		ИнтернетПочта.Послать(Письмо);
	Исключение
		ТекстОшибки = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;
	
	ИнтернетПочта.Отключиться();
	
	Возврат ТекстОшибки;
	
КонецФункции

&НаСервере
Процедура ПроверитьНастройкиУчетнойЗаписи()
	
	ПроверкаЗавершиласьСОшибками = Ложь;
	
	СообщениеСервераВходящейПочты = "";
	Если ИспользоватьДляПолучения Тогда
		СообщениеСервераВходящейПочты = ПроверитьПодключениеКСерверуВходящейПочты();
	КонецЕсли;
	
	СообщениеСервераИсходящейПочты = "";
	Если ИспользоватьДляОтправки Тогда
		СообщениеСервераИсходящейПочты = ПроверитьПодключениеКСерверуИсходящейПочты();
	КонецЕсли;
	
	ТекстОшибки = "";
	Если Не ПустаяСтрока(СообщениеСервераИсходящейПочты) Тогда
		ТекстОшибки = НСтр("ru = 'Не удалось подключиться к серверу исходящей почты:'" + Символы.ПС)
			+ СообщениеСервераИсходящейПочты + Символы.ПС;
	КонецЕсли;
	
	Если Не ПустаяСтрока(СообщениеСервераВходящейПочты) Тогда
		ТекстОшибки = ТекстОшибки
			+ НСтр("ru = 'Не удалось подключиться к серверу входящей почты:'" + Символы.ПС)
			+ СообщениеСервераВходящейПочты;
	КонецЕсли;
	
	СообщенияОбОшибках = СокрЛП(ТекстОшибки);
			
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		ПроверкаЗавершиласьСОшибками = Истина;
	Иначе
		Попытка
			СоздатьУчетнуюЗапись();
		Исключение
			ПроверкаЗавершиласьСОшибками = Истина;
			СообщенияОбОшибках = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьУчетнуюЗапись()
	
	СистемнаяУчетнаяЗапись = Справочники.УчетныеЗаписиЭлектроннойПочты.СистемнаяУчетнаяЗаписьЭлектроннойПочты;
	НастроитьСистемнуюУчетнуюЗапись = КонтекстныйРежим И ВидУчетнойЗаписи = "Общая"
		И Не РаботаСПочтовымиСообщениями.УчетнаяЗаписьНастроена(СистемнаяУчетнаяЗапись)
		И Справочники.УчетныеЗаписиЭлектроннойПочты.ИзменениеРазрешено(СистемнаяУчетнаяЗапись);
	
	Если НастроитьСистемнуюУчетнуюЗапись Тогда
		УчетнаяЗаписьСсылка = СистемнаяУчетнаяЗапись;
	КонецЕсли;
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.УчетныеЗаписиЭлектроннойПочты");
	Если Не УчетнаяЗаписьСсылка.Пустая() Тогда
		ЭлементБлокировки.УстановитьЗначение("Ссылка", УчетнаяЗаписьСсылка);
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		Если УчетнаяЗаписьСсылка.Пустая() Тогда
			УчетнаяЗапись = Справочники.УчетныеЗаписиЭлектроннойПочты.СоздатьЭлемент();
			УчетнаяЗапись.УстановитьСсылкуНового(СсылкаНовойУчетнойЗаписи);
		Иначе
			УчетнаяЗапись = УчетнаяЗаписьСсылка.ПолучитьОбъект();
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств(УчетнаяЗапись, ЭтотОбъект);
		УчетнаяЗапись.ИмяПользователя = ИмяОтправителяПисем;
		УчетнаяЗапись.Пользователь = ИмяПользователяДляПолученияПисем;
		УчетнаяЗапись.ПользовательSMTP = ИмяПользователяДляОтправкиПисем;
		УчетнаяЗапись.ВремяОжидания = ДлительностьОжиданияСервера;
		УчетнаяЗапись.ОставлятьКопииСообщенийНаСервере = ОставлятьКопииПисемНаСервере;
		УчетнаяЗапись.ПериодХраненияСообщенийНаСервере = ?(ОставлятьКопииПисемНаСервере И УдалятьПисьмаССервера И Протокол = "POP", ПериодХраненияСообщенийНаСервере, 0);
		УчетнаяЗапись.ПротоколВходящейПочты = Протокол;
		УчетнаяЗапись.Наименование = НазваниеУчетнойЗаписи;
		Если ВидУчетнойЗаписи = "Персональная" Тогда
			УчетнаяЗапись.ВладелецУчетнойЗаписи = Пользователи.ТекущийПользователь();
		Иначе
			УчетнаяЗапись.ВладелецУчетнойЗаписи = Справочники.Пользователи.ПустаяСсылка();
		КонецЕсли;
		УчетнаяЗапись.ДополнительныеСвойства.Вставить("НеПроверятьИзменениеНастроек");
		
		УчетнаяЗапись.Записать();
		УчетнаяЗаписьСсылка = УчетнаяЗапись.Ссылка;
		ТребуетсяПодтверждениеЗакрытияФормы = Ложь;
		
		УстановитьПривилегированныйРежим(Истина);
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(УчетнаяЗаписьСсылка, ПарольДляПолученияПисем);
		ОбщегоНазначения.ЗаписатьДанныеВБезопасноеХранилище(УчетнаяЗаписьСсылка, ПарольДляОтправкиПисем, "ПарольSMTP");
		УстановитьПривилегированныйРежим(Ложь);
			
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Ошибка при создании учетной записи электронной почты'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

&НаСервере
Функция ИнтернетПочтовыйПрофиль(ДляПолучения = Ложь)
	
	Профиль = Новый ИнтернетПочтовыйПрофиль;
	Если ДляПолучения Или ТребуетсяВходНаСерверПередОтправкой Тогда
		Если Протокол = "IMAP" Тогда
			Профиль.АдресСервераIMAP = СерверВходящейПочты;
			Профиль.ИспользоватьSSLIMAP = ИспользоватьЗащищенноеСоединениеДляВходящейПочты;
			Профиль.ПарольIMAP = ПарольДляПолученияПисем;
			Профиль.ПользовательIMAP = ИмяПользователяДляПолученияПисем;
			Профиль.ПортIMAP = ПортСервераВходящейПочты;
		Иначе
			Профиль.АдресСервераPOP3 = СерверВходящейПочты;
			Профиль.ИспользоватьSSLPOP3 = ИспользоватьЗащищенноеСоединениеДляВходящейПочты;
			Профиль.Пароль = ПарольДляПолученияПисем;
			Профиль.Пользователь = ИмяПользователяДляПолученияПисем;
			Профиль.ПортPOP3 = ПортСервераВходящейПочты;
		КонецЕсли;
	КонецЕсли;
	
	Если Не ДляПолучения Тогда
		Профиль.POP3ПередSMTP = ТребуетсяВходНаСерверПередОтправкой;
		Профиль.АдресСервераSMTP = СерверИсходящейПочты;
		Профиль.ИспользоватьSSLSMTP = ИспользоватьЗащищенноеСоединениеДляИсходящейПочты;
		Профиль.ПарольSMTP = ПарольДляОтправкиПисем;
		Профиль.ПользовательSMTP = ИмяПользователяДляОтправкиПисем;
		Профиль.ПортSMTP = ПортСервераИсходящейПочты;
	КонецЕсли;
	
	Профиль.Таймаут = ДлительностьОжиданияСервера;
	
	Возврат Профиль;
	
КонецФункции

&НаКлиенте
Процедура НастроитьПараметрыПодключенияАвтоматически()
	
	СообщенияОбОшибках = НСтр("ru = 'Не удалось определить настройки подключения. 
	|Настройте параметры подключения вручную.'");
	
	Если СтрНайти(НРег(АдресЭлектроннойПочты), "@gmail.com") > 0 Тогда
		СообщенияОбОшибках = СообщенияОбОшибках + Символы.ПС
			+ НСтр("ru = 'См. также рекомендации по настройке почты Gmail:
					|http://buh.ru/articles/documents/42429/#briefly_43166'");
	КонецЕсли;
	
	ПроверкаЗавершиласьСОшибками = Ложь;
	
	ДлительнаяОперация = НачатьПоискНастроекУчетнойЗаписи();
	
	ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
	ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗавершенииПоискаНастроек", ЭтотОбъект);
	ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОписаниеОповещения, ПараметрыОжидания);
	
КонецПроцедуры

&НаСервере
Функция НачатьПоискНастроекУчетнойЗаписи()
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Поиск настроек почтового сервера'");
	
	Возврат ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения, "Справочники.УчетныеЗаписиЭлектроннойПочты.ОпределитьНастройкиУчетнойЗаписи",
		АдресЭлектроннойПочты, ПарольДляПолученияПисем, ИспользоватьДляОтправки, ИспользоватьДляПолучения);
	
КонецФункции

&НаКлиенте
Процедура ПриЗавершенииПоискаНастроек(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		ПроверкаЗавершиласьСОшибками = Истина;
		ПерейтиНаСледующуюСтраницу();
		Возврат;
	КонецЕсли;
	
	НайденныеНастройки = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
	
	ПроверкаЗавершиласьСОшибками = ИспользоватьДляОтправки И Не НайденныеНастройки.ДляОтправки 
		Или ИспользоватьДляПолучения И Не НайденныеНастройки.ДляПолучения;
		
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, НайденныеНастройки);
	Если Не ПроверкаЗавершиласьСОшибками Тогда
		Попытка
			СоздатьУчетнуюЗапись();
		Исключение
			ПроверкаЗавершиласьСОшибками = Истина;
			СообщенияОбОшибках = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
		ОповеститьОбИзменении(СсылкаНовойУчетнойЗаписи);
	КонецЕсли;
	ПерейтиНаСледующуюСтраницу();
	
КонецПроцедуры

#КонецОбласти
