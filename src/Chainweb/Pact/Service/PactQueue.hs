-- |
-- Module: Chainweb.Pact.Service.PactQueue
-- Copyright: Copyright © 2018 Kadena LLC.
-- License: See LICENSE file
-- Maintainer: Mark Nichols <mark@kadena.io>
-- Stability: experimental
--
-- Pact execution service queue for Chainweb

module Chainweb.Pact.Service.PactQueue
    ( addRequest
    , addHttpRequest
    , addResponse
    , getNextHttpRequest
    , getNextRequest
    , getNextResponse
    , RequestId(..)
    , RequestHttpMsg(..)
    , RequestType(..)
    , ResponseHttpMsg(..)
    , sendCloseMsg
    ) where

import Control.Concurrent.STM.TQueue
import Control.Concurrent.STM.TVar
import Control.Monad.STM

import Chainweb.Pact.Service.Types

-- | Add a request to the Pact execution queue
addRequest :: TQueue RequestMsg -> RequestMsg -> IO ()
addRequest q msg = do
    atomically $ writeTQueue q msg

-- | Send special 'close' message to stop the processing thread
sendCloseMsg :: TQueue RequestMsg -> IO ()
sendCloseMsg q = do
    atomically $ writeTQueue q CloseMsg

--TODO: remove or combine with 'getNextRequest
-- | Add a request to the Pact execution queue
addHttpRequest :: TVar (TQueue RequestHttpMsg) -> RequestHttpMsg -> IO ()
addHttpRequest qVar msg = do
    q <- readTVarIO qVar
    atomically $ writeTQueue q msg

-- | Get the next available request from the Pact execution queue
getNextRequest :: TQueue RequestMsg -> IO RequestMsg
getNextRequest q = do
    atomically $ readTQueue q

--TODO: remove or combine with 'getNextRequest
getNextHttpRequest :: TVar (TQueue RequestHttpMsg) -> IO RequestHttpMsg
getNextHttpRequest qVar = do
    q <- readTVarIO qVar
    atomically $ readTQueue q

-- | Add a response to the Pact execution response queue
addResponse :: TVar (TQueue ResponseHttpMsg) -> ResponseHttpMsg -> IO ()
addResponse qVar msg = do
    q <- readTVarIO qVar
    atomically $ writeTQueue q msg
    return ()

-- | Get the next available response from the Pact execution response queue
getNextResponse :: TVar (TQueue ResponseHttpMsg) -> IO ResponseHttpMsg
getNextResponse qVar = do
    q <- readTVarIO qVar
    atomically $ readTQueue q
