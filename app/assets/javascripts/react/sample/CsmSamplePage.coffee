@CsmSamplePage = React.createClass
  getInitialState: ->
    data: @props.data.data
    tab: 1

  render: ->
    klasses = [1, 2, 3].map (idx)=>
      new ClassName
        'item': true
        'active': @state.tab == idx

    <div className='csm sample page'>
      <div className='ui message warning'>
        Knowledge Camp 知识库产品概念演示
      </div>

      <div className='ui tabular menu'>
        <a className={klasses[0]} onClick={@tab(1)}>阅读视图</a>
        <a className={klasses[1]} onClick={@tab(2)}>大纲视图</a>
        <a className={klasses[2]} onClick={@tab(3)}>图形视图</a>
      </div>

      {
        switch @state.tab
          when 1
            <CSMReader root={@state.data[0]} />
          when 2
            <PathNodesNav nodes={@state.data} />
          when 3
            <div></div>
      }

    </div>

  tab: (idx)->
    =>
      @setState tab: idx

CSMReader = React.createClass
  getInitialState: ->
    dash_string = location.href.split('#')[1]
    if dash_string? and dash_string.length
      nav_params = dash_string.split(',')
    else
      nav_params = []

    nav_params: nav_params

  render: ->
    # 根据 dash_param 获取 current_node
    current_node = @props.root
    nav_params = @state.nav_params
    for x in nav_params
      nav_param = x.split(':')
      path_idx = nav_param[0]
      node_idx = nav_param[1]
      path = current_node.paths[path_idx]
      current_node = path.nodes[node_idx]

    <div className='csm-reader'>
      <NodeContent node={current_node} reader={@} />
    </div>

  nav_into: (nav_param)->
    console.log nav_param
    nav_params = @state.nav_params
    nav_params.push nav_param
    @setState {
      nav_params: nav_params
    }, ->
      location.href = "/sample##{nav_params.join(',')}"

    # location.href = "/sample#{@state.dash_param}"

NodeContent = React.createClass
  render: ->
    current_node = @props.node

    <div>
    {
      title = current_node.text || current_node.from
      <h2 className='ui header node-title'>{title}</h2>
    }
    {
      if current_node.target?
        <div className='target-content'>
          <h3 className='ui header'>认知目标：{current_node.target}</h3>
          <Placeholder desc='对认知目标的概述是？' />
        </div>
    }
    {
      if current_node.paths?
        <div className='paths-content'>
          <h3 className='ui header'>认知线索：</h3>
          <div className='paths'>
          {
            for path, idx in current_node.paths
              <PathNodesContent key={idx} path_idx={idx} path={path} reader={@props.reader} />
          }
          </div>
        </div>
    }
    </div>

PathNodesContent = React.createClass
  render: ->
    <div className='path-nodes-content'>
    {
      for node, idx in @props.path.nodes
        title = node.text || node.from
        nav_param = "#{@props.path_idx}:#{idx}"

        <div key={idx} className='path-node'>
          <a className='node-title-link' href='javascript:;' onClick={@reader_nav_into(nav_param)}>
            <i className='icon arrow right' /> {title}
          </a>
        </div>
    }
    </div>

  reader_nav_into: (nav_param)->
    =>
      @props.reader.nav_into(nav_param)

Placeholder = React.createClass
  render: ->
    <div className='csm-placeholder'>
      <i className='icon file text outline' /> {@props.desc}
    </div>

PathNodesNav = React.createClass
  render: ->
    <div className='csm-path-nodes-nav'>
    {
      for node, idx in @props.nodes
        <Node key={idx} node={node} />
    }
    </div>

Node = React.createClass
  getInitialState: ->
    close: true

  render: ->
    {from, target, paths, text} = @props.node

    if text?
      <div className='csm-node text'>
        <div className='text'>TEXT: {text}</div>
      </div>
    else
      klass = new ClassName
        'csm-node path': true
        'no-paths': not paths.length

      <div className={klass}>
        {
          if paths.length
            if @state.close
              <a href='javascript:;' className='toggle' onClick={@toggle}>
                <i className='icon chevron right' />
              </a>
            else
              <a href='javascript:;' className='toggle' onClick={@toggle}>
                <i className='icon chevron down' />
              </a>
        }
        <div className='from'>FROM: {from}</div>
        <div className='target'>TARGET: {target}</div>
        {
          if @state.close and paths.length
            <div className='paths closed'>...</div>
          else
            <div className='paths'>
            {
              for path, idx in paths
                <PathNodesNav key={idx} nodes={path.nodes} />
            }
            </div>
        }
      </div>

  toggle: ->
    @setState close: not @state.close