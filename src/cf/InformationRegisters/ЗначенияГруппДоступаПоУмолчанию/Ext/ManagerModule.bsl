﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// ТехнологияСервиса.ВыгрузкаЗагрузкаДанных

// Подключается в ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриРегистрацииОбработчиковВыгрузкиДанных.
//
// Параметры:
//   Контейнер - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерКонтейнера
//   МенеджерВыгрузкиОбъекта - ОбработкаОбъект.ВыгрузкаЗагрузкаДанныхМенеджерВыгрузкиДанныхИнформационнойБазы
//   Сериализатор - СериализаторXDTO
//   Объект - КонстантаМенеджерЗначения
//          - СправочникОбъект
//          - ДокументОбъект
//          - БизнесПроцессОбъект
//          - ЗадачаОбъект
//          - ПланСчетовОбъект
//          - ПланОбменаОбъект
//          - ПланВидовХарактеристикОбъект
//          - ПланВидовРасчетаОбъект
//          - РегистрСведенийНаборЗаписей
//          - РегистрНакопленияНаборЗаписей
//          - РегистрБухгалтерииНаборЗаписей
//          - РегистрРасчетаНаборЗаписей
//          - ПоследовательностьНаборЗаписей
//          - ПерерасчетНаборЗаписей
//   Артефакты - Массив из ОбъектXDTO
//   Отказ - Булево
//
Процедура ПередВыгрузкойОбъекта(Контейнер, МенеджерВыгрузкиОбъекта, Сериализатор, Объект, Артефакты, Отказ) Экспорт
	
	УправлениеДоступомСлужебный.ПередВыгрузкойНабораЗаписей(Контейнер, МенеджерВыгрузкиОбъекта, Сериализатор, Объект, Артефакты, Отказ);
	
КонецПроцедуры

// Конец ТехнологияСервиса.ВыгрузкаЗагрузкаДанных

#КонецОбласти

#КонецОбласти

#КонецЕсли
