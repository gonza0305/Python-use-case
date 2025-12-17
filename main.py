import argparse
import logging
import sys
import time
from pathlib import Path

from dotenv import load_dotenv

# Import our pipeline
from src.pipeline import run_pipeline
from src.utils import setup_logger

# Initial logger configuration for the entry point
logger = setup_logger("Entrypoint")


def parse_args():
    """
    Parse command line arguments.
    This allows running the script with options like:
    python main.py --env prod --verbose
    """
    parser = argparse.ArgumentParser(description="NYC Collisions ETL Pipeline")

    parser.add_argument(
        "--env",
        type=str,
        default="dev",
        choices=["dev", "prod"],
        help="Environment to run the pipeline in (default: dev)",
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Increase output verbosity to DEBUG",
    )

    return parser.parse_args()


def main():
    """
    Main orchestration function.
    """
    # 1. Time measurement (basic engineering KPI)
    start_time = time.time()

    # 2. Parse arguments
    args = parse_args()

    # 3. Environment configuration
    # Load environment variables from .env if it exists
    load_dotenv()

    # Adjust log level according to --verbose flag
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
        logger.debug("Debug mode enabled.")

    logger.info(f"Starting ETL Pipeline in environment: {args.env.upper()}")

    # 4. Safe execution
    try:
        # Launch the pipeline here.
        # Note: You could pass 'args.env' to run_pipeline if your config supports environments.
        run_pipeline()

        elapsed = time.time() - start_time
        logger.info(f"Pipeline completed successfully in {elapsed:.2f} seconds.")

        # Successful exit (Code 0)
        sys.exit(0)

    except KeyboardInterrupt:
        logger.warning("Pipeline execution interrupted by user.")
        sys.exit(130)

    except Exception as e:
        # 5. Catch-all for unhandled errors
        # It's vital to log the error and EXIT WITH ERROR (sys.exit(1))
        # so that Airflow/Jenkins mark the task as FAILED.
        logger.critical(f"Pipeline failed with critical error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
