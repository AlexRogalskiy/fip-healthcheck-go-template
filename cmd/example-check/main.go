// Copyright (c) 2021 SIGHUP s.r.l All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"fmt"
	"os"

	internal "github.com/sighupio/fip-healthcheck-go-template/internal/example-check"
	pkg "github.com/sighupio/fip-healthcheck-go-template/pkg/example-check"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
)

var logLevel string

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
	lvl, err := log.ParseLevel(logLevel)
	if err != nil {
		log.WithField("log-level", logLevel).Fatal("incorrect log level")

		return fmt.Errorf("incorrect log level")
	}

	log.SetLevel(lvl)
	log.WithField("log-level", logLevel).Debug("log level configured")

	return nil
}

func init() {
	rootCmd.PersistentFlags().StringVar(&logLevel, "log-level", "info", "logging level (debug, info...)")
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
