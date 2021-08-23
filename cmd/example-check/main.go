// Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"fmt"
	"os"

	"github.com/sighupio/fip-healthcheck-go-template/internal/config"
	internal "github.com/sighupio/fip-healthcheck-go-template/internal/example-check"
	pkg "github.com/sighupio/fip-healthcheck-go-template/pkg/example-check"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

var cfg = &config.CheckConfig{}

var rootCmd = &cobra.Command{
	PersistentPreRunE: cmdConfig,
	Use:               "example-check",
	Short:             "example-check TBD",
	Long:              "TBD",
	Run: func(cmd *cobra.Command, args []string) {
		// Do business logic
		internal.Hello()
		pkg.Hello()
	},
}

func cmdConfig(cmd *cobra.Command, args []string) error {
	lvl, err := log.ParseLevel(cfg.LogLevel)
	if err != nil {
		log.WithField("log-level", cfg.LogLevel).Fatal("incorrect log level")

		return fmt.Errorf("incorrect log level")
	}

	log.SetLevel(lvl)
	log.WithField("log-level", cfg.LogLevel).Debug("log level configured")

	return nil
}

func init() {
	rootCmd.PersistentFlags().StringVar(&cfg.LogLevel, "log-level", "info", "logging level (debug, info...)")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		log.WithError(err).Fatal("error in the cli. Exiting")
		os.Exit(1)
	}
}
