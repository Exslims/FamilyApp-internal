# FamilyApp-internal

#### Описание

Тема: Бытовой помощник (учет финансов). 

Будет основан на модульной архитектуре, где первым модулем будет **учет финансов** (запись, аналитика, прогнозирование и тп). 

#### Схема
![image](https://user-images.githubusercontent.com/11871586/172071267-284af666-3459-462f-872e-9e74c9a22b69.png)
#### Описание бизнес кейсов


В системе заводится юзер, юзер может создать кошелек, либо присоедениться к существующему кошельку, который был создан другим пользователем. Юзер может иметь несколько кошельков, так же как и кошелек может быть общим на несколько юзеров, но владелец только 1.  

Пользователь может управлять транзакциями внутри 1 кошелька. Транзакции относятся только к 1 конкретному кошельку. При добавлении транзакции указывается юзер который ее добавил, автор может быть только 1. 

Юзер может настраивать(добавлять/удалять) категории внутри кошелька, категории относятся только к одному кошельку. Категории имеют иерархию, которая будет ограничена 2 уровнями (чтобы не усложнять). Например: Транспорт -> Такси


