{-# LANGUAGE NoImplicitPrelude #-}
module Import
    ( module Import
    ) where

import Foundation            as Import
import Import.NoFoundation   as Import

getStudy :: Text -> Handler Study
getStudy key = do
  studies <- appStudies <$> getYesod
  maybe notFound pure $ lookup key studies
