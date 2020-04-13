# Plato3

A bot for spamming socrative.com

 _**"No law or ordinance is mightier than understanding"
 <br> ~Plato**_

## About Plato

Plato3 is an AHK bot that joins a specified room on socrative.com enters a random StudendID and selects random answers. It takes around 4.03 seconds for the program to do a complete cycle. It supports both Instant Feedback and Open Navigation modes, as well as these internal features
* Require Names (must be on for bot to work)
* Shuffle Questions 
* Shuffle Answers
* Show Question Feedback 
* Show Final Score

Teacher paced mode is not supported and never will be. Only one instance of the program can be running at the same time. However this can be bypassed with Virtual Machines and is the recommended way to run the bot.

## Requirements

* [AHK package](https://www.autohotkey.com/)
* Windows OS (recommended 7 or newer)
* Internet Explorer (recommended 11 or newer)


## Setup & Configuration 

Before you run Plato3 you need to configure it.
1. Download and host index.html on a website of your choosing, it doesn't have to be the only thing on the website. Plato3 will work as long as there is
    ```javascript
    <script>
        function refresh() {
            location.reload(true);
        }
    </script>
    ```
    and this
    ```html
    <body>
    <p>Command: <span id="command">start</span></p>
    <p>Room name: <span id="roomname">ZDUKAUUZW</span></p>
    </body>
    ```
    There are three commands that are implemented, they don't serve much of a purpose outside of system resource management and pausing the bot:
       * start - starts the bot, can be started before the room is opened, the bot will simply restart itself every 8 seconds until a quiz starts, it will use up slightly more system resources.
       * pause - pauses the bot, it will check every 4 second for new commands
       * stop - same as pause but the bot will wait 60 seconds
    <br><br>
2. Download Plato3.ahk and open it with a text editor. Find this piece of code (line 18)<br>
    `auth:= OpenInvisible(" ")` (line 18)<br>
    and put in your website's address between the quotation marks,
    <br><br>
    Next go to
    <br>
    `end:= A_TickCount+8000` (line65)
    the bot is optimized for 5 questions, add 450 to the 8000 for each extra question that you expect to get in the quiz. For five or less questions leave it as it is. For six questions it should look like this `end:= A_TickCount+8450`
    <br><br>
    This line `random, rand, 16000000, 18999999` (line 84) generates student's ID between the range of 16000000->18999999, you can change this setting to any other set of numbers. Plato3 currently does not support name only IDs.
    <br><br>
3. After this is done you can save the document and run Plato3. I recommended setting up multiple VMs and adding Plato3 to the startup folder (starts with system boot). If you decide to do that uncomment `;Sleep,40000` (line 3) by removing `;` . Your website (`index.html`) does NOT have to be up for the bot to be active as a process, it will simply wait for the website to load. 

## TODOs
* Allow for usage of student's name instead of the ID
* Add `exit` command
* Allow for IDs/Name to be fetched from `index.html`, rather than generated
* Add a video tutorial
