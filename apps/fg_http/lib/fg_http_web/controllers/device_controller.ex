defmodule FgHttpWeb.DeviceController do
  @moduledoc """
  Implements the CRUD for a Device
  """

  use FgHttpWeb, :controller
  alias FgHttp.{Devices, Devices.Device}

  plug FgHttpWeb.Plugs.SessionLoader

  def index(conn, _params) do
    devices = Devices.list_devices(conn.assigns.current_user.id)
    render(conn, "index.html", devices: devices)
  end

  def new(conn, _params) do
    changeset = Devices.change_device(%Device{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"device" => %{"public_key" => _public_key} = device_params}) do
    our_params = %{
      "user_id" => conn.assigns.current_user.id,
      "name" => "Default",
      "ifname" => "wg0"
    }

    all_params = Map.merge(device_params, our_params)

    case Devices.create_device(all_params) do
      {:ok, device} ->
        redirect(conn, to: Routes.device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    render(conn, "show.html", device: device)
  end

  def edit(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    changeset = Devices.change_device(device)
    render(conn, "edit.html", device: device, changeset: changeset)
  end

  def update(conn, %{"id" => id, "device" => device_params}) do
    device = Devices.get_device!(id)

    case Devices.update_device(device, device_params) do
      {:ok, device} ->
        conn
        |> put_flash(:info, "Device updated successfully.")
        |> redirect(to: Routes.device_path(conn, :show, device))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", device: device, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    device = Devices.get_device!(id)
    {:ok, _device} = Devices.delete_device(device)

    conn
    |> put_flash(:info, "Device deleted successfully.")
    |> redirect(to: Routes.device_path(conn, :index))
  end
end