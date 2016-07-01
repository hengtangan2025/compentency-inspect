@ChatBox = React.createClass
  getInitialState: ->
    messages: @props.data.messages

  render: ->
    message_input_area_data =
      send_message_text: @send_message_text
      ctrl_and_enter: @ctrl_and_enter

    <div className="chat-box">
      <MessageList data={@state.messages}/>
      <MessageInputArea data={message_input_area_data} ref="message_input_area"/>
    </div>
   
  ctrl_and_enter: (e)->
    console.log e.keyCode
    @input_keycodes ||= []
    @input_keycodes[e.keyCode] = true
    console.log @input_keycodes[13]
    console.log @input_keycodes[17]
    if @input_keycodes[13] && @input_keycodes[17] then console.log 1

  send_message_text: (e)->
     message_text = @refs.message_input_area.refs.message_input.value
     message =
      chater: 
        id: 1
        name: "我"
      text: message_text
     message_array = @state.messages
     message_array.push(message) 
     @setState
        messages: message_array
     @return_message(message_text,message_array)
     @refs.message_input_area.refs.message_input.value = " "

   return_message: (message_text,message_array)->
      jQuery.ajax
        url: @props.data.post_url
        type: "POST"
        data: {text: message_text}
      .done (data)=>
        message_array.push(data)
        @setState
          messages: message_array
        jQuery(".message-list").scrollTop(jQuery(".message-list")[0].scrollHeight)
      
MessageList = React.createClass
  render: ->
    <div className="message-list">
      {
        for item in @props.data
          replace_text = item.text.replace(/\r?\n/g, "</br>")
          a = {__html: replace_text}
          if item.chater.id == 1 then textclass = "left-message"
          if item.chater.id == 2 then textclass = "right-message"
          <div className=textclass key={item.text}>
             <div className="chater">{item.chater.name}:</div>
             <div className="text" dangerouslySetInnerHTML={a} />
          </div>  
      }
    </div>

MessageInputArea = React.createClass
  render: ->
    <div className="text-input">
      <div className="textarea">
        <textarea type="text" placeholder="输入你想说的话" ref="message_input" onKeyDown={@props.data.ctrl_and_enter}/>
      </div>
      <button className="ui button" onClick={@props.data.send_message_text}>发送</button>
    </div>