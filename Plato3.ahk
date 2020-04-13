#SingleInstance, Force
Disabled:= ComObjError(0)

;Close all existing InternetExplorer(IE) Applications, allows for easy testing
Loop
{
	process, Exist, iexplore.exe
	if(!ErrorLevel= 0){
		process, Close, iexplore.exe
	}
	else{
		break
	}
}

Start:
;Open invisible IE window - interface, allows for easy management if you have this running on multiple VMs
;Website from which u can manage the bot
auth:= OpenInvisible(" ")
Loop{
	;Limit auth load time
	authMaxLoad:= A_TickCount+4000
	;If website is not up
	if(!auth.document.getElementByID("command")){
		auth.quit()
		sleep, 4000
		goto, Start
	}
	;Refresh to get the updated version of the website
	auth.document.parentWindow.execScript("refresh()")
	;While loading
	while (auth.readystate != 4) or (auth.busy) and (A_TickCount>=AuthMaxLoad)
		sleep,50
	;Get the command from the elemnt with command ID
	command:=auth.document.getElementByID("command").innerText

	if(command="pause")
		sleep,4000

	if(command="stop")
		sleep, 60000

	if(command="start"){
		Execute:
		;This is the core of the bot, I'm refering to each execution of this
		;loop as "iteration"
		Loop{
			;Get the code for logging into a room
			roomName:=auth.document.getElementByID("roomname").innerText
			AuthMaxLoad:=A_TickCount+4000
			;In case the auth website goes down during execution of this
			if(!auth.document.getElementByID("command")){
				auth.quit()
				sleep, 4000
				goto, Start
			}
			auth.document.parentWindow.execScript("refresh()")
			while (auth.readystate != 4) or (auth.busy) and A_TickCount>=AuthMaxLoad
				sleep,50
			command:=auth.document.getElementByID("command").innerText
			;As long as command is set to start the script will be working
			if(command!="start")
				break

			;Limit the lifespan of one iteration, in case the program gets stuck while executing
			end:= A_TickCount+8000
			wb:= Open("https://b.socrative.com/login/student/")
			;While the page with room name input is loading
			while(!wb.document.getElementByID("studentRoomName") && A_TickCount<=end)
				sleep,100
			;Put in the room name
			wb.document.getElementByID("studentRoomName").value:=roomName
			;Not really neccessary but just in case
			wb.document.getElementByID("studentRoomName").focus()
			;Send a space and delete to bypass anti-measures preventing from editing studenRoomName
			send,{space}
			sleep,50
			send, {backspace}
			sleep,100
			;Wait and submit, {Enter} is used because if .click() is used
			;it will let you in but won't go throught the quiz
			send,{Enter}
			;Randomize a StudentID
			random,, %A_TickCount%
			random, rand, 16000000, 18999999
			;Wait for student name input
			while(!wb.document.getElementByID("student-name-input") && A_TickCount<=end){
				sleep,100
				;In some rare cases the website would go back to the room name input
				;after successfully put in room name, don't know why so here is a reset
				if(wb.document.getElementByID("join-room-container")&& A_TickCount>(end-4000)){
					wb.quit()
					goto, Execute
				}
			}
			;Not sure why this is here but I probably put it here for a reason
			if(A_TickCount>=end){
				wb.quit()
				break
			}
			;Send in the StudentID
			send,%rand%
			send,{Enter}

			;Keep answering the questions as long as the max time is not
			;exceeded, if you have more than 5-6 question you might want to
			;adjust end, 450ms for each extra question if you want to be safe
			;you can probably get away with 200 or 300 per extra question
			while(A_TickCount<=end){
				;Anwser question, returns end=0 if it's the last questions
				;and the quiz is open in navigation mode, if in instant feedback mode
				;the exiting will be handled by ifPopUp() function
				;end is passed in so that the max limit for one iteration is still implemented
				if(answerQ(wb,end)=0)
					break
				;This manages all popups so that if the quizz shows reults
				;for each question or just the final result it will still work.
				;It also takes care of ending the iteration if end of the quiz
				;is reached in the instant feedback mode
				isEnd:= ifPopUp(wb, end)
				if(isEnd==true)
					break
			}
			;Close the IE window if this iteration
			wb.quit()
		}
	}
}
;Opend IE window
Open(URL){
    wb:= ComObjCreate("InternetExplorer.Application")
	;The window is visible on the screen, this is a requirement so that send, {space} works
    wb.Visible := True
	;Go to the passed in URL
    wb.Navigate(URL)
    while (wb.readystate != 4) or (wb.busy)
		sleep,100
	;Return the IE window so that it can be still managed outside of this function
    return wb
}

;Does the same thing as Open() but keeps the window invisible, it's optional
;but recommended. Notice that the fucntion doesn't wait for the page to load
;as it's handled at the begging of the script
OpenInvisible(URL){
    wb:= ComObjCreate("InternetExplorer.Application")
	;wb.Visible := True
    wb.Navigate(URL)
    return wb
}


ifPopUp(wb,end){
	;While waiting for next/first question to load
	while(!wb.document.getElementByID("take-quiz-master-container") && A_TickCount<=end)
	{
		;Instant feedback popup, appears after each question is answered
		;This gets rid of it
		if(wb.document.getElementByID("feedback-popup"))
			wb.document.getElementByID("submit-feedback-button").click()

		;;End the current iteration after the final results popup is detected
		;indicating that you anwsered all questions
		if(wb.document.getElementByID("results-container"))
			return true

		;This ends the iteration if there is no final results popup
		;but you anwsered all questions.
		if(wb.document.getElementByID("waiting-for-teacher-container"))
			return true
	}
}

answerQ(wb,end){
	;Wait for the question
	while(!wb.document.getElementByID("take-quiz-master-container") && A_TickCount<=end)
		sleep,100

	;Count all the anwsers
	randMax:=(wb.document.getElementsByClassName("answer-option-letter").length)-1

	;Randomize an answer, with a max of randMax
	random,, %A_TickCount%
	random, rand,0,%randMax%
	;Select the answer
	wb.document.getElementsByClassName("answer-option-letter").item[rand].click()

	;Wait after selecting the answer, while the answer is not selected, in case of delay
	while(!wb.document.getElementsByClassName("selected").item[0] && A_TickCount<=end)
		sleep,100

	;This clicks the submit button in instant feedback mode
	if(wb.document.getElementByID("submit-button"))
		wb.document.getElementByID("submit-button").click()

	;This moves to the next question in the open navigation mode and detected
	;the usage of open navigaton mode
	if(wb.document.getElementsByClassName("question-range").item[0]){
		;Click next question button that also work as the submit buttton
		wb.document.getElementsByClassName("next-question-button").item[0].click()

		;If all question anwsered
		if(wb.document.getElementsByClassName("question-range").item[0].getElementsByTagName("b").item[0].innerText
		=wb.document.getElementsByClassName("question-range").item[0].getElementsByTagName("b").item[1].innerText)
		{
			;End the iteration after leaving this function
			end:=0
			;Click the Finish button, otherwise the last question won't be recorded
			wb.document.getElementByID("student-finish-quiz").click()
			sleep,300
		}
	}
	;While still in the same question, waiting for the next question to load
	while(wb.document.getElementsByClassName("selected").item[0] && A_TickCount<=end)
		sleep,100

	return end
}
