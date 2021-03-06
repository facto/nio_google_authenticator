defmodule NioGoogleAuthenticator do
  @moduledoc """
  This module provides simple wrapper functions to create secrets for
  Google Authenticator as well as validate them with a time based token.
  """

  @doc """
  Creates a random Base 32 encoded string
  """
  def generate_secret do
    :crypto.strong_rand_bytes(10)
      |> Base.encode32
  end

  @doc """
  Generates a valid token based on a secret
  """
  def generate_token(secret) do
    :pot.totp(secret)
  end

  @doc """
  Creates a URL for a Google QR code that includes a secret,
  label, and issuer. Scanning this QR code in the Google
  Authenticator app allows the generation of validation tokens.
    """
  def generate_url(secret, label, issuer \\ default_issuer()) do
    "https://chart.googleapis.com/chart?cht=qr&chs=200x200&chl=" <>
    URI.encode_www_form("otpauth://totp/#{label}?issuer=#{issuer}&secret=#{secret}")
  end

  defp default_issuer, do: Application.get_env(:nio_google_authenticator, :issuer)

  @doc """
  Validates a given token based on a secret.

  Returns {:ok, :pass} if the token is valid and
  {:error, :invalid_token} if it is not.
  """
  def validate_token(secret, token) when is_binary(secret) and is_binary(token) do
    case :pot.valid_totp(token, secret) do
      true -> {:ok, :pass}
      false -> {:error, :invalid_token}
    end
  end

  def validate_token(_, _), do: {:error, "Both secret and token must be strings"}
end
