{-# Language OverloadedStrings #-}
{-|
Module      : Main
Description : Decoder driver for BurntSushi TOML test suite
Copyright   : (c) Eric Mertens, 2023
License     : ISC
Maintainer  : emertens@gmail.com

Decode TOML into JSON for use with <https://github.com/BurntSushi/toml-test>

-}
module Main (main) where

import Data.Aeson qualified as Aeson
import Data.ByteString.Lazy qualified as BS
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Text (Text)
import Data.Time.Format ( defaultTimeLocale, formatTime )
import System.Exit (exitFailure)
import Toml qualified
import Toml.Pretty (prettyValue)

main :: IO ()
main =
 do txt <- getContents
    case Toml.parse txt of
        Left{} -> exitFailure
        Right t -> BS.putStr (Aeson.encode t)

simple :: Text -> Toml.Value -> Aeson.Value
simple ty value = Aeson.object ["type" Aeson..= ty, "value" Aeson..= prettyValue value]

instance Aeson.ToJSON Toml.Value where
    toJSON v =
        case v of
            Toml.Table t     -> Aeson.toJSON t
            Toml.Array a     -> Aeson.toJSON a
            Toml.String s    -> Aeson.object ["type" Aeson..= ("string"::Text), "value" Aeson..= s]
            Toml.Integer {}  -> simple "integer"        v
            Toml.Float   {}  -> simple "float"          v
            Toml.Bool{}      -> simple "bool"           v
            Toml.TimeOfDay x -> simple "time-local"     v
            Toml.ZonedTime x -> simple "datetime"       v
            Toml.LocalTime x -> simple "datetime-local" v
            Toml.Day x       -> simple "date-local"     v