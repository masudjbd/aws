{-# LANGUAGE RecordWildCards, TypeFamilies, FlexibleInstances, MultiParamTypeClasses, OverloadedStrings, TupleSections #-}

-- | GET GetDate
--
--   Receive current date string from Route53 service that can be used as date string for
--   authenticating REST requests to Route53.
--
--   <http://docs.amazonwebservices.com/Route53/latest/DeveloperGuide/RESTAuthentication.html>
-- 
module Aws.Route53.Commands.GetDate where

import           Aws.Core
import           Aws.Route53.Core
import           Data.Maybe
import           Data.Time                  (UTCTime)
import           Data.Time.Format           (parseTime)
import           System.Locale              (defaultTimeLocale)
import           Data.ByteString.Char8      (unpack)
import qualified Network.HTTP.Types         as HTTP

data GetDate = GetDate deriving (Show)

newtype GetDateResponse = GetDateResponse { date :: UTCTime } deriving (Show)

instance SignQuery GetDate where
  type Info GetDate = Route53Info
  signQuery GetDate info sd = SignedQuery 
    { sqMethod = Get
    , sqProtocol = route53Protocol info
    , sqHost = route53Endpoint info
    , sqPort = route53Port info
    , sqPath = "/date/"
    , sqQuery = []
    , sqDate = Just $ signatureTime sd
    , sqAuthorization = Nothing
    , sqContentType = Nothing
    , sqContentMd5 = Nothing
    , sqAmzHeaders = []
    , sqOtherHeaders = []
    , sqBody = Nothing
    , sqStringToSign = ""
    }

instance ResponseConsumer r GetDateResponse where
  type ResponseMetadata GetDateResponse = ()
  responseConsumer _ _ _ headers _ = return $ GetDateResponse date
    where
    -- TODO add proper error handling
    date = fromJust $ do 
      str <- findHeaderValue headers HTTP.headerDate
      -- FIXME: this is probably to restrictive. We should support full rfc1123
      parseTime defaultTimeLocale "%a, %d %b %Y %H:%M:%S %Z" (unpack str)

getDate :: GetDate
getDate = GetDate

instance Transaction GetDate GetDateResponse where

