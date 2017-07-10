## [Revel - framework for Go](https://revel.github.io)


### Содержание
* [Запуск](#Запуск) 
* [Правила](#Правила) 
* [Run.bat](#run.bat)
* [Middleware(Interceptors)](#middlewareinterceptors)
* [Контроллеры](#Контроллеры)
* [Модели](#Модели)
* [Маршрутизация](#Маршрутизация)
* [Валидация](#Валидация)
* [Локализация](#Локализация) 
* [Jobs](#jobs)
* [Проблемы - Решения](#Проблемы-Решения) 

---

### Запуск 
**Приложения после скачки с репо**
1. git clone https/ project
2. запустить **Install_pkg.bat** - установит и обновит нужные пакеты в src
3. запустить RUN.bat - где написано `revel run app`


**Приложения на сервере**
1. Скопировать построенный проект на сервер
2. Запустить : `run.sh` - чере комманду: `bash run.sh`, если не работает читай пункт 3
3. **Ошибка** может возникнуть тогда просто ввести вот это:
```
./bars -importPath bars -srcPath ./src -runMode prod
```



### Правила
* в папке **src** должна быть папка **bars** - это текущий проект
* в .gitignore должны быть (vendors):
```
puller.bat
pusher.bat
/src/github.com
/src/golang.org
/src/gopkg.in
```

### Run.bat
```go
@ECHO OFF

REM SET GOROOT=C:\GO
SET GOPATH=%CD%
SET PATH=%GOPATH%\BIN;%PATH%;

rem SET GOOS=linux
rem SET GOARCH=amd64
rem SET CGO_ENABLED=0

REM packages
rem go get github.com/revel/revel
rem go get github.com/revel/cmd/revel

revel run project
pause

```


---


### Middleware(Interceptors)
+ есть 2 способа юзать перехватчик: 
    * Присоеденить к классу(как метод); 
    * Использовать в отдельном файле(как функцию)**(проверен)**. Создаем файл **./controllers/Middleware.go** и там пишем какую то проверка и создаем функцию `init(){...}` в которой надо указать на какой контроллер поцепить эту проверку:
```go
package controllers

import "github.com/revel/revel"

// Проверка авторизации
func checkUser(c *revel.Controller) revel.Result {

    cookk, err :=  c.Request.Cookie("Test")
    if err != nil{ return c.Redirect(Test.Creater)  }
    
    ss         :=  cookk.Value
    cook       :=  string(ss)
    
    
    // fmt.Println("Кукочка : ", cook)
    // fmt.Println(c.Name)


   if  cook != ""  {
        return nil
    } else{
    	return c.Redirect(Test.Creater)
    }

}


// Init all middleware
func init() {
       revel.InterceptFunc(checkUser, revel.BEFORE,    &IndexController{})
    // revel.InterceptFunc(doNothing, revel.AFTER,     &AuthControler{})
    // revel.InterceptFunc(checkUser, revel.BEFORE, &Test{})
}
```

### Контроллеры
Контроллеры храняться в папке **controllers** в пространстве с таким же именем. Есть возможность создать **базовый контроллер** от которого потом **унаследовать объект Revel и методы этого класса:**
###### BaseController.go
```go
package controllers

import "github.com/revel/revel"

type BaseController struct {
	*revel.Controller
}

 func (c BaseController) Index() {
    return c.RenderText("hi there")
 }

```


###### UserController.go
```go
package controllers

import "github.com/revel/revel"

type UserController struct {
	BaseController
}

 func (c UserController) Index() {
    return c.RenderText("now its user controller")
 }

```

### Модели
Модели храняться в папке **models** в пространстве с таким же именем. Для работы с моделью надо её создать и объявить структуру(класс этой модели) и структура может быть пустой:
###### User.go
```go
package models


type User struct { /*... - может быть пустой */
}

 func (User *User) AddUser() {
    // ... some code here
 }

```



### Маршрутизация
Маршруты храняться в папке **conf/routes**. Синтаксис прост : `Метод  -  адрес  -  Контроллер.метод`
###### вот так можно получить передаваемый в GET `:id` в контроллере - `c.Params.Get("id")`

```yaml
# Its comment, dont type slash in comment it will brake system
GET      /events/           SomeController.Index                 
POST     /events/           SomeController.Add     
PUT      /events/del/:id    SomeController.Edit    
DELETE   /events/edit       SomeController.Del    
PUT      /events/change     SomeController.Change   

```



### Валидация
 Чтобы выводило все ошибки после всей проверки надо изменить **src/github.com/revel/revel/validation.go:196** строка в функции `ValidationFilter(c *Controller, fc []Filter())` изменить `c.ViewArgs["errors"] = c.Validation.ErrorMap()` на `c.RenderArgs["errors"] = c.Validation.Errors` 
 
###### EventsController.go - Index()
 ```go
func (c EventsController) Index() revel.Result {
...
  // Проверка данных
    if c.EventValidator(title, email) {
       return c.Redirect("/events/")
    }
...
}
``` 
 
 ###### EventsController.go - EventValidator()
```go
func (c EventsController) EventValidator(title, email string) bool {

	// проверка
    c.Validation.Required(title).Message("Title is required")
    c.Validation.MaxSize(title, 40).Message("Title must be less than 40 symbols, u tard")

    c.Validation.Required(email).Message("Email is required")
    c.Validation.Email(email).Message("Email is not valid, u piece of poo")

    // если нашлись ошибки после проверки
	if c.Validation.HasErrors() {
     c.Validation.Keep()           // в переменную errors записуем все ошибки  (на шаблоне - {{range .errors}} {{.}} {{end}})
     c.FlashParams()               // все данные которые пришли формы доступны в Flash (на шаблоне - {{.flash.email_field}})
     return true
	} else{
	 return false
	}
}
```

### Локализация
*Установка локализации идет в 3 шага (проверки):*
  1. Revel ищет куки с префиксом `REVEL` по-ум. и постфиксом `_LANG` , префикс устанавливаеться в файл conf/app.conf -> `cookie.prefix = REVEL`, и выходит что оно ищет куку с названием - **REVEL_LANG**, которая содержит название текущего языка - `'ru', 'en', 'fr'` и так далее.
    2. Если куки `REVEL_LANG` - не существует, начнеться проверка **Accept-Language HTTP header**, другими словами проверка башки запроса  которая приходит от клиента
    3. Если не удаеться определить язык и по **2 пункту**, тогда устанавливаеться язык по-ум. который лежит в conf/app.conf -> `i18n.default_language = en`
    4. Переменные перевода лежат в `/messages/messages.en,  messages.ru...`
    5. На шаблоне юзать так - `{{msg . "greeting"}}`, в контроллере так - `c.Message("greeting")`


### Jobs
1. Создать в контроллерах(папке) - **ex_job.go**:
```go
package controllers

import (
    "time"
    "fmt"

    "github.com/revel/revel"
    "github.com/revel/modules/jobs/app/jobs"
)

type ReminderEmails struct {
    // Filtered
}

func (e ReminderEmails) Run() {
     fmt.Println("hello")
}

func init() {
    revel.OnAppStart(func() {
        // jobs.Schedule("0 0 0 * * ?",  ReminderEmails{})
        // jobs.Schedule("@midnight",    ReminderEmails{})
        // jobs.Schedule("@every 24h",   ReminderEmails{})
        jobs.Every(1 * time.Second,    ReminderEmails{})  // каждую секунду пишет "hello"
    })
}

```


### Проблемы - Решения
1. **Revel - вывод ошибок**: в стандартной сборке после валидации данных Revel отдает только 1 строку ошибки валидации, а точнее первое сообщение. **Решение** - в файле **src/github.com/revel/revel/validation.go** в функции `ValidationFilter(c *Controller, fc []Filter())` изменить `c.RenderArgs["errors"] = c.Validation.ErrorMap(`) на `c.RenderArgs["errors"] = c.Validation.Errors`

2. **Если при запуске** пишет: `no mode found`.  **src/github.com/revel/revel/revel.go** - надо закоментить следуещие:
```
if !Config.HasSection(mode) {
	// 	log.Fatalln("app.conf: No mode found:", mode)
	// }
```


