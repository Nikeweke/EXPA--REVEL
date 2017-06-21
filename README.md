## Revel - framework for Go
###### [Revel - official site](https://revel.github.io/manual/database.html)


### Запуск Run.bat не делать через консоль ATom'a, а кликом на файле


#### Запуск приложения после скачки с репо
1. git clone https/ project
2. запустить **Install_pkg.bat** - установит и обновит нужные пакеты в src
2. из папки **bin** взять **revel.exe** и скопировать в **System32** для глобальной видимости`(или как то подругому сделать его видимым глобально, нужно для сборки и запуска проекта)`
3. запустить RUN.bat - запуск и построения проекта


#### Запуск приложения на сервере
* Скопировать построенный проект на сервер
* Запустить : `run.sh` - чере комманду: `bash run.sh`
* **Ошибка** может возникнуть тогда просто ввести вот это:
```
./bars -importPath bars -srcPath ./src -runMode prod
```

###### Golang frameworks:
* **Beego** - https://medium.com/@richardeng/a-word-from-the-beegoist-d562ff8589d7#.x374zbcum
* **Revel** - https://revel.github.io/manual/database.html

---

## Оглавление

* [Правила](#Правила) 
* [Middleware(Interceptors)](#middlewareinterceptors)
* [Контроллеры](#Контроллеры)
* [Модели](#Модели)
* [Маршрутизация](#Маршрутизация)
* [Валидация](#Валидация)
* [Локализация](#Локализация) 



### Правила
* в папке **src** должна быть папка **bars** - это текущий проект
* в .gitignore должны быть (короче vendors):
```
puller.bat
pusher.bat
/src/github.com
/src/golang.org
/src/gopkg.in
```


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
###### *Установка локализации идет в 3 шага (проверки):*
  1. Revel ищет куки с префиксом `REVEL` по-ум. и постфиксом `_LANG` , префикс устанавливаеться в файл conf/app.conf -> `cookie.prefix = REVEL`, и выходит что оно ищет куку с названием - **REVEL_LANG**, которая содержит название текущего языка - `'ru', 'en', 'fr'` и так далее.
    2. Если куки `REVEL_LANG` - не существует, начнеться проверка **Accept-Language HTTP header**, другими словами проверка башки запроса  которая приходит от клиента
    3. Если не удаеться определить язык и по **2 пункту**, тогда устанавливаеться язык по-ум. который лежит в conf/app.conf -> `i18n.default_language = en`
    4. Переменные перевода лежат в `/messages/messages.en,  messages.ru...`
    5. На шаблоне юзать так - `{{msg . "greeting"}}`, в контроллере так - `c.Message("greeting")`




