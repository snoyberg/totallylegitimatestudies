{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Studies where

import Import

getStudiesR :: Handler Html
getStudiesR = do
  studies <- appStudies <$> getYesod
  defaultLayout $ do
    setTitle "Studies"
    $(widgetFile "studies")
