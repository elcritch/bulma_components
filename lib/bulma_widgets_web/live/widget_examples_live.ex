defmodule BulmaWidgetsWeb.WidgetExamplesLive do
  use BulmaWidgetsWeb, :live_view

  use BulmaWidgets.Actions, pubsub: BulmaWidgetsWeb.PubSub
  alias BulmaWidgets.Widgets.ScrollMenu
  alias BulmaWidgets.Widgets.SelectionMenu
  alias BulmaWidgets.Widgets.ActionButton
  alias BulmaWidgets.Widgets.TabView
  alias BulmaWidgets.Widgets.VertTabView
  alias BulmaWidgets.Action.UpdateHooks

  require Logger

  def mount(_params, _session, socket) do
    # Logger.debug("tab_check_sensor:comp:mount: #{inspect(socket, pretty: true)}")
    # Logger.debug("WidgetExamplesLive:mount:params: #{inspect(get_connect_params(socket), pretty: true)}")
    params = get_connect_params(socket)
    theme = params["bulma_theme"] || "light"
    Logger.warning("widget:setting bulma theme: #{inspect theme}")

    {:ok,
     socket
     |> assign(:shared, %{})
    #  |> assign(:bulma_theme , theme)
     |> assign(:page_title, "Widget Examples")
     |> assign(:menu_items, BulmaWidgetsWeb.MenuUtils.menu_items())
     |> assign(:wiper_mode, nil)
     |> assign(:wiper_selection, nil)
     |> assign(:wiper_options, nil)
    #  |> mount_broadcast(topics: ["test-value-set"])
     |> mount_shared(topics: ["test-value-set"])
    }
  end

  def handle_info({:updates, assigns}, socket) do
    Logger.debug("WidgetExamplesLive:comp:update: #{inspect(assigns, pretty: true)}")
    # send message to listen here!

    {:noreply, Actions.update(assigns, socket)}
  end

  def render(assigns) do

    ~H"""
    <.container>
      <.title notification={true} size={3}>Widget Examples</.title>
      <.button phx-click="test" is-fullwidth is-loading={false}>
        Click me
      </.button>

        <p> shared: <%= @shared |> inspect() %> </p>

      <.live_component
        module={ScrollMenu}
        id="wiper_mode_test"
        is-fullwidth
        is-info
        values={[{"Regular", 1}, {"Inverted", -1}]}
      >
        <:label :let={{k, _}}>
          Test: <%= k %>
        </:label>
      </.live_component>

      <br />

      <.tagged is-link label="Wiper Modes:" value={prettify @wiper_mode}/>
      <br />

      <.live_component
        module={ScrollMenu}
        is-primary
        id="wiper_speed"
        values={[{"Slow", 1}, {"Fast", 2}]}
        extra_actions={[
          #{Event.Commands,
          #commands: fn evt ->
          #  Logger.info("Wiper:hi!!! #{inspect({evt.id, evt.data}, pretty: false)}")
          #  evt
          #end},
          Widgets.set_action_data(into: :wiper_mode, to: self())
        ]}
      >
        <:label :let={{k, _}}>
          Test: <%= k %>
        </:label>
      </.live_component>

      <.live_component
        module={ScrollMenu}
        id="value_set"
        values={[{"A", 1}, {"B", 2}]}
        data={@shared[:value_set]}
        extra_actions={[
          # broadcast value
          Widgets.send_action_data("test-value-set", into: :value_set),
          #Widgets.send_shared("test-value-set", loading: true),
        ]}
      >
        <:default_label> Example </:default_label>
      </.live_component>

      <.live_component
          id="test-start"
          module={ActionButton}
          is-primary
          extra_actions={
            [
              Widgets.send_shared("test-value-set",
                loading: true
              ),
          ]}
          >
        Start
      </.live_component>

      <.live_component
          id="test-stop"
          module={ActionButton}
          is-primary
          extra_actions={
            [
              Widgets.send_shared("test-value-set",
                loading: false
              ),
          ]}
          >
        Stop
      </.live_component>

      <br>

      <.live_component module={ActionButton} id="test-run" is-fullwidth extra_actions={[]}>
        Click me
      </.live_component>

      <br>
      <.title size={4}>Non-shared local only Dropdown</.title>
      <.tagged is-link label="Wiper Selection:" value={prettify @wiper_selection}/>

      <.live_component
        module={SelectionMenu}
        id="wiper_mode"
        is-fullwidth
        is-info
        label="Wiper Modes"
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
        extra_actions={[
          {UpdateHooks,
            to: self(),
            hooks: [
              fn evt ->
                Logger.warning("wiper_mode:selection:update: #{inspect(evt, pretty: true)} ")
                %{evt | socket: evt.socket |> assign(:wiper_selection, evt.data)}
              end
            ]
          }
        ]}
      >
      </.live_component>

      <br />

      <.title size={4}>Shared and Cached Dropdown</.title>
      <.tagged is-link label="Wiper Options:" value={Event.key(@shared[:wiper_options]) }/>

      <.live_component
        module={SelectionMenu}
        id="wiper_options"
        is-fullwidth
        is-info
        label="Wiper Modes"
        data={@shared[:wiper_options]}
        values={[
          {"Regular", 1},
          {"Inverted", -1}
        ]}
        extra_actions={[
          Widgets.send_action_data("test-value-set", into: :wiper_options),
        ]}
      >
      </.live_component>

      <br />

      <.title size={4}>Example Tabs</.title>
      <br />

      <.live_component
        module={TabView}
        id="example_tabs"
        data={"tab1"}
        is-boxed
      >
        <:tab name="Tab 1" key="tab1">
          <.tab_one />
        </:tab>
        <:tab name="Tab 2" key="tab2">
          <.tab_two />
        </:tab>
      </.live_component>

      <br/>
      <.live_component
        module={VertTabView}
        id="example_vert_tabs"
        data={"tab1"}
        is-boxed
        min_menu_width={"7em"}
        min_menu_height={"20em"}
      >
        <:tab name="Tab 1" key="tab1">
          <.tab_one />
        </:tab>
        <:tab name="Tab 2" key="tab2">
          <.tab_two />
        </:tab>
        <:tab name="Tab 3" key="tab3">
          <.tab_three />
        </:tab>
      </.live_component>

      <div class="modal is-active">
        <div class="modal-content" style="position: absolute; bottom: 1em; ">
          <div class="content has-text-centered" >

            <.message>
              <:header>
                <p>Hello World</p>
                <button class="delete" aria-label="delete"></button>
              </:header>
              <:body>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                <strong>Pellentesque risus mi</strong>, tempus quis placerat ut, porta nec
                nulla. Vestibulum rhoncus ac ex sit amet fringilla. Nullam gravida purus
                diam, et dictum <a>felis venenatis</a> efficitur. Aenean ac
                <em>eleifend lacus</em>, in mollis lectus. Donec sodales, arcu et
                sollicitudin porttitor, tortor urna tempor ligula, id porttitor mi magna a
                neque. Donec dui urna, vehicula et sem eget, facilisis sodales sem.
              </:body>
            </.message>

          </div>
        </div>
        <button class="modal-close is-large" aria-label="close"></button>
      </div>

      <br/><br/><br/>
    </.container>
    """
  end

  @spec handle_event(<<_::32>>, any(), any()) :: {:noreply, any()}
  def handle_event("test", _params, socket) do
    Logger.info("test!")

    {:noreply,
     socket
     |> put_flash!(:info, "It worked!")}
  end

  def tab_one(assigns) do
    ~H"""
      <.box>
        <p>First view</p>
      </.box>
    """
  end
  def tab_two(assigns) do
    ~H"""
      <.box>
        <p>Second view</p>
      </.box>
    """
  end
  def tab_three(assigns) do
    ~H"""
      <.box>
        <p>Third view</p>
        <br>
        <br>
        <br>
        <br>
      </.box>
    """
  end


end
